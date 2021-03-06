open Mods

let usage_msg =
  "KaSim "^Version.version_string^":\n"^
    "Usage is KaSim [-i] input_file [-e events | -t time] [-p points] [-o output_file]\n"

let close_desc opt_env =
  let () = Kappa_files.close_all_out_desc () in
  List.iter (fun d -> close_in d) !Parameter.openInDescriptors ;
  match opt_env with
  | None -> ()
  | Some env -> Environment.close_desc env

let () =
  let options = [
    ("--version",
     Arg.Unit (fun () -> Format.print_string Version.version_msg;
			 Format.print_newline () ; exit 0),
     "display KaSim version");
    ("-i",
     Arg.String (fun fic ->
		 Parameter.inputKappaFileNames:= fic:: (!Parameter.inputKappaFileNames)),
     "name of a kappa file to use as input (can be used multiple times for multiple input files)");
    ("-e",
     Arg.Int (fun i -> if i < 0 then Parameter.maxEventValue := None
		       else let () = Parameter.maxTimeValue:= None in
			    Parameter.maxEventValue := Some i),
     "Number of total simulation events, including null events (negative value for unbounded simulation)");
    ("-t",
     Arg.Float(fun t -> Parameter.maxTimeValue := Some t ;
			Parameter.maxEventValue := None),
     "Max time of simulation (arbitrary time unit)");
    ("-p", Arg.Set_int Parameter.pointNumberValue,
     "Number of points in plot");
    ("-var",
     Arg.Tuple
       [Arg.Set_string Parameter.tmp_var_name;
	Arg.String
	  (fun var_val ->
	   Parameter.alg_var_overwrite :=
	     (!Parameter.tmp_var_name,
	      try Nbr.of_string var_val with
		Failure _ ->
		raise (Arg.Bad ("\""^var_val^"\" is not a valid value")))
	       ::!Parameter.alg_var_overwrite)],
     "Set a variable to a given value");
    ("-o", Arg.String Kappa_files.set_data,
     "file name for data output") ;
    ("-d",
     Arg.String Kappa_files.set_dir,
     "Specifies directory name where output file(s) should be stored") ;
    ("-load-sim", Arg.Set_string Parameter.marshalizedInFile,
     "load simulation package instead of kappa files") ;
    ("-make-sim", Arg.String Kappa_files.set_marshalized,
     "save kappa files as a simulation package") ;
    ("-dump-cc", Arg.String Kappa_files.set_ccFile,
     "file name for dumping the domain of observables") ;
    ("--implicit-signature",
     Arg.Unit (fun () ->
	       Format.eprintf "--implicitSignature is currently unplugged.@.";
	       Parameter.implicitSignature := true),
     "Program will guess agent signatures automatically") ;
    ("-seed", Arg.Int (fun i -> Parameter.seedValue := Some i),
     "Seed for the random number generator") ;
    ("--eclipse", Arg.Set Parameter.eclipseMode,
     "enable this flag for running KaSim behind eclipse plugin") ;
    ("--emacs-mode", Arg.Set Parameter.emacsMode,
     "enable this flag for running KaSim using emacs-mode") ;
    ("--compile", Arg.Set Parameter.compileModeOn,
     "Display rule compilation as action list") ;
    ("--debug", Arg.Set Parameter.debugModeOn,
     "Enable debug mode") ;
    ("--safe", Arg.Set Parameter.safeModeOn,
     "Enable safe mode") ;
    ("--backtrace", Arg.Set Parameter.backtrace,
     "Backtracing exceptions") ;
    ("--batch", Arg.Set Parameter.batchmode,
     "Set non interactive mode (always assume default answer)") ;
    ("--gluttony",
     Arg.Unit (fun () -> Gc.set { (Gc.get()) with
				  Gc.space_overhead = 500 (*default 80*) } ;),
     "Lower gc activity for a faster but memory intensive simulation") ;
    ("-rescale-to", Arg.Int (fun i -> Parameter.rescale:=Some i),
     "Rescale initial concentration to given number for quick testing purpose");
  ]
  in
  try
    Arg.parse options
	      (fun fic ->
	       Parameter.inputKappaFileNames:=
		 fic::(!Parameter.inputKappaFileNames))
	      usage_msg;
    let abort =
      match !Parameter.inputKappaFileNames with
      | [] -> !Parameter.marshalizedInFile = ""
      | _ -> false
    in
    if abort then (prerr_string usage_msg ; exit 1) ;
    let sigint_handle = fun _ ->
      raise (ExceptionDefn.UserInterrupted
	       (fun t e ->
		Format.sprintf
		  "Abort signal received after %E t.u (%d events)" t e))
    in
    let _ = Sys.set_signal Sys.sigint (Sys.Signal_handle sigint_handle) in

    Printexc.record_backtrace !Parameter.backtrace ; (*Possible backtrace*)

    (*let _ = Printexc.record_backtrace !Parameter.debugModeOn in*)

    Format.printf "+ Command line is: @[<h>%a@]@."
		  (Pp.array Pp.space
			    (fun i f s ->
			     Format.fprintf
			       f "'%s'" (if i = 0 then "KaSim" else s)))
		  Sys.argv;

    let result =
      Ast.init_compil() ;
      List.iter (fun fic -> KappaLexer.compile Format.std_formatter fic)
		!Parameter.inputKappaFileNames ;
      !Ast.result in

    let theSeed =
      match !Parameter.seedValue with
      | Some seed -> seed
      | None ->
	 begin
	   Format.printf "+ Self seeding...@." ;
	   Random.self_init() ;
	   Random.bits ()
	 end
    in
    Random.init theSeed ;
    Format.printf
      "+ Initialized random number generator with seed %d@." theSeed;

    let (kasa_state,env, cc_env, counter, graph, new_state) =
      match !Parameter.marshalizedInFile with
      | "" ->
	 Eval.initialize Format.std_formatter !Parameter.alg_var_overwrite result
      | marshalized_file ->
	 try
	   let d = open_in_bin marshalized_file in
	   let () =
	     if !Parameter.inputKappaFileNames <> [] then
	       Format.printf
		 "+ Loading simulation package %s (kappa files are ignored)...@."
		 marshalized_file
	     else
	       Format.printf "+Loading simulation package %s...@."
			     marshalized_file in
	   let kasa_state,env,cc_env,counter,graph,new_state =
	     (Marshal.from_channel d :
		Export_to_KaSim.Export_to_KaSim.state*Environment.t*Connected_component.Env.t*Counter.t*
		  Rule_interpreter.t * State_interpreter.t) in
	   let () = Pervasives.close_in d  in
	   let () = Format.printf "Done@." in
	   (kasa_state,env,cc_env,counter,graph,new_state)
	 with
	 | _exn ->
	    Debug.tag
	      Format.std_formatter
	      "!Simulation package seems to have been created with a different version of KaSim, aborting...@.";
	    exit 1
    in
    let () = Kappa_files.with_marshalized
	       (fun d -> Marshal.to_channel
			   d (env,cc_env,counter) [Marshal.Closures]) in
    let () = Kappa_files.with_ccFile
	       (fun f -> Connected_component.Env.print_dot f cc_env) in
    let () = Export_to_KaSim.Export_to_KaSim.dump_errors_light kasa_state in
    let _kasa_state = Export_to_KaSim.Export_to_KaSim.flush_errors kasa_state in
    ExceptionDefn.flush_warning Format.err_formatter ;
    if !Parameter.compileModeOn then exit 0 else ();

    Kappa_files.setCheckFileExists() ;

    let () = Plot.create (Kappa_files.get_data ()) in
    let () =
      if !Parameter.pointNumberValue > 0 then
	Plot.plot_now
	  env counter.Mods.Counter.time
	  (State_interpreter.observables_values env counter graph new_state) in

    Parameter.initSimTime () ;
    let () =
      State_interpreter.loop Format.std_formatter env cc_env counter graph new_state
    in
    Format.printf "Simulation ended";
    if Counter.null_event counter = 0 then Format.print_newline()
    else
      let () =
	Format.printf " (eff.: %f, detail below)@."
		      ((float_of_int (Counter.event counter)) /.
			 (float_of_int
			    (Counter.null_event counter + Counter.event counter))) in
      Counter.print_efficiency Format.std_formatter counter ;
  with
  | ExceptionDefn.Malformed_Decl er ->
     let () = ExceptionDefn.flush_warning Format.err_formatter in
     let () = close_desc None in
     let () = Pp.error Format.pp_print_string er in
     exit 2
  | ExceptionDefn.Internal_Error er ->
     let () = ExceptionDefn.flush_warning Format.err_formatter in
     let () = close_desc None in
     let () =
       Pp.error
	 (fun f x -> Format.fprintf f "Internal Error (please report):@ %s" x)
	 er in
     exit 2
  | Invalid_argument msg ->
     let () = ExceptionDefn.flush_warning Format.err_formatter in
     let () = close_desc None in
     let s = "" (*Printexc.get_backtrace()*) in
     let () = Format.eprintf "@.@[<v>***Runtime error %s***@,%s@]@." msg s in
    exit 2
  | ExceptionDefn.UserInterrupted f ->
     let () = ExceptionDefn.flush_warning Format.err_formatter in
     let () = close_desc None in
     let msg = f 0. 0 in
     let () =Format.eprintf "@.***Interrupted by user: %s***@." msg in
     exit 1
  | Sys_error msg ->
     let () = ExceptionDefn.flush_warning Format.err_formatter in
     let () = close_desc None in
     let () = Format.eprintf "%s@." msg in
     exit 2
