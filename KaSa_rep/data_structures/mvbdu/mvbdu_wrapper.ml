

module type Mvbdu =
  sig
    type handler = (Boolean_mvbdu.memo_tables,Boolean_mvbdu.mvbdu_dic,Boolean_mvbdu.list_dic,bool,int) Memo_sig.handler
    type mvbdu
    type hconsed_list
    type 'output constant = Remanent_parameters_sig.parameters -> handler ->   Exception.method_handler -> Exception.method_handler * handler * 'output
    type ('input,'output) unary =  Remanent_parameters_sig.parameters -> handler ->   Exception.method_handler -> 'input -> Exception.method_handler * handler * 'output
    type ('input1,'input2,'output) binary = Remanent_parameters_sig.parameters -> handler ->   Exception.method_handler -> 'input1 -> 'input2 -> Exception.method_handler * handler * 'output
  
    val init: Remanent_parameters_sig.parameters -> Exception.method_handler -> Exception.method_handler * handler 
    val is_init: unit -> bool 
    val equal: mvbdu -> mvbdu -> bool 
    val equal_with_logs: (mvbdu,mvbdu,bool) binary
    val mvbdu_false: mvbdu constant
    val mvbdu_true:  mvbdu constant
    val mvbdu_not: (mvbdu,mvbdu) unary
    val mvbdu_id:  (mvbdu,mvbdu) unary
    val mvbdu_unary_true: (mvbdu,mvbdu) unary
    val mvbdu_unary_false: (mvbdu,mvbdu) unary 
    val mvbdu_and:  (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_or: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_xor: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_nand: (mvbdu,mvbdu,mvbdu) binary
    val mvbdu_nor: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_imply: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_rev_imply: (mvbdu,mvbdu,mvbdu) binary
    val mvbdu_equiv: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_nimply: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_nrev_imply: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_bi_true: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_bi_false: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_fst: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_snd: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_nfst: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_nsnd: (mvbdu,mvbdu,mvbdu) binary 
    val mvbdu_redefine: (mvbdu,hconsed_list,mvbdu) binary 
    val build_list: ((int * int) list,hconsed_list) unary  
    val build_sorted_list: ((int * int) list,hconsed_list) unary
    val build_reverse_sorted_list: ((int * int) list,hconsed_list) unary
    val print: out_channel -> string -> mvbdu -> unit
    val print_list: out_channel -> string -> hconsed_list -> unit 
  end


module type Internalized_mvbdu =
  sig
    type mvbdu
    type hconsed_list
    val init: Remanent_parameters_sig.parameters -> unit  
    val is_init: unit -> bool 
    val equal: mvbdu -> mvbdu -> bool 
    val mvbdu_false: unit -> mvbdu
    val mvbdu_true:  unit -> mvbdu 
    val mvbdu_not: mvbdu -> mvbdu 
    val mvbdu_id:  mvbdu -> mvbdu 
    val mvbdu_unary_true: mvbdu -> mvbdu
    val mvbdu_unary_false: mvbdu -> mvbdu
    val mvbdu_and: mvbdu -> mvbdu -> mvbdu
    val mvbdu_or:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_xor:  mvbdu -> mvbdu -> mvbdu 
    val mvbdu_nand:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_nor:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_imply:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_rev_imply:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_equiv:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_nimply:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_nrev_imply:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_bi_true:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_bi_false:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_fst:  mvbdu -> mvbdu -> mvbdu
    val mvbdu_snd:  mvbdu -> mvbdu -> mvbdu 
    val mvbdu_nfst:  mvbdu -> mvbdu -> mvbdu 
    val mvbdu_nsnd:  mvbdu -> mvbdu -> mvbdu 
    val mvbdu_redefine: mvbdu -> hconsed_list -> mvbdu
    val build_list: (int * int) list ->  hconsed_list 
    val build_sorted_list: (int * int) list -> hconsed_list
    val build_reverse_sorted_list: (int * int) list -> hconsed_list
    val print: out_channel -> string -> mvbdu -> unit
    val print_list: out_channel -> string -> hconsed_list -> unit 

  end


    
module type Nul =
  sig 
  end 
module Make (M:Nul)  = 
  (struct 
    type handler = (Boolean_mvbdu.memo_tables,Boolean_mvbdu.mvbdu_dic,Boolean_mvbdu.list_dic,bool,int) Memo_sig.handler  
    type mvbdu = bool Mvbdu_sig.mvbdu
    type hconsed_list = int List_sig.list
    type 'output constant = Remanent_parameters_sig.parameters -> handler ->   Exception.method_handler -> Exception.method_handler * handler * 'output
    type ('input,'output) unary =  Remanent_parameters_sig.parameters -> handler ->   Exception.method_handler -> 'input -> Exception.method_handler * handler * 'output
    type ('input1,'input2,'output) binary = Remanent_parameters_sig.parameters -> handler ->   Exception.method_handler -> 'input1 -> 'input2 -> Exception.method_handler * handler * 'output

    let init,is_init = 
      let used = ref None in 
      let init parameter error = 
	match 
	  !used 
	with 
	| Some a -> 
	  Exception.warn parameter error (Some "Mvbdu_wrapper.ml") (Some "MVBDU should be initialised once only")  Exit (fun _ -> a)
    	| None -> 
	  begin
	    let error,handler = Boolean_mvbdu.init_remanent parameter error in 
	    let () = used := Some handler in 
	    error,handler 
	  end
      in
      let is_init () = !used != None 
      in
      init,is_init
	      
    let equal = Mvbdu_core.mvbdu_equal 
    let equal_with_logs p h e a b = e,h,equal a b 
    let lift0 string f parameters handler error = 
      match 
	 f parameters handler error parameters
      with 
      | error,(handler,Some a) -> error,handler,a 
      | error,(handler,None) -> 
        let error, a =
          Exception.warn parameters error (Some "Mvbdu_wrapper.ml") (Some string)  Exit (fun _ -> failwith "Cannot recover from bugs in constant initilization") in 
        error, handler, a
    
    let mvbdu_true = lift0 "line 55, bdd_true" Boolean_mvbdu.boolean_mvbdu_true
    let mvbdu_false = lift0 "line 56, bdd_false" Boolean_mvbdu.boolean_mvbdu_false
    
    let lift1 string f parameters handler error a = 
      match 
	 f parameters handler error parameters a
      with 
      | error,(handler,Some a) -> error,handler,a 
      | error,(handler,None) -> 
        let error, a =
          Exception.warn parameters error (Some "Mvbdu_wrapper.ml") (Some string)  Exit (fun () -> a) 
        in 
	error, handler, a
      
    let lift1bis string f parameters handler error a = 
      let a,(b,c) = 
	 f (Boolean_mvbdu.list_allocate parameters) error parameters handler a 
      in a,b,c
    
    let lift1ter string f parameters handler error a = 
      let a,(b,c) = 
	 f (Boolean_mvbdu.list_allocate parameters) parameters error handler a
      in a,b,c

    let lift2 string f parameters handler error a b = 
      match 
	f parameters handler error parameters a b
      with 
      | error,(handler,Some a) -> error,handler,a 
      | error,(handler,None) -> 
        let error, a =
          Exception.warn parameters error (Some "Mvbdu_wrapper.ml") (Some string)  Exit (fun () -> a) 
        in 
	error, handler, a

    let lift2bis string f parameters handler error a b = 
      match 
	f parameters error  parameters handler a b
      with 
      | error,(handler,Some a) -> error,handler,a 
      | error,(handler,None) -> 
        let error, a =
          Exception.warn parameters error (Some "Mvbdu_wrapper.ml") (Some string)  Exit (fun () -> a) 
        in 
	error, handler, a
    let (mvbdu_not: (mvbdu,mvbdu) unary) = lift1 "line 80, bdd_not" Boolean_mvbdu.boolean_mvbdu_not

    let mvbdu_id parameters handler error a = error, handler, a

    let mvbdu_unary_true parameters handler error _ =  mvbdu_true parameters handler error 
    let mvbdu_unary_false parameters handler error _ = mvbdu_false parameters handler error 

    let mvbdu_and = lift2 "line_86, bdd_and" Boolean_mvbdu.boolean_mvbdu_and 
    let mvbdu_or = lift2 "line 87, bdd_or" Boolean_mvbdu.boolean_mvbdu_or 
    let mvbdu_xor = lift2 "line 88, bdd_false" Boolean_mvbdu.boolean_mvbdu_xor 
    let mvbdu_nand = lift2 "line 89, bdd_nand" Boolean_mvbdu.boolean_mvbdu_nand
    let mvbdu_nor =  lift2 "line 90, bdd_nor" Boolean_mvbdu.boolean_mvbdu_nor 
    let mvbdu_imply =  lift2 "line 91, bdd_imply" Boolean_mvbdu.boolean_mvbdu_imply
    let mvbdu_rev_imply =  lift2 "line 92, bdd_imply" Boolean_mvbdu.boolean_mvbdu_is_implied 
    let mvbdu_equiv =  lift2 "line 93, bdd_equiv" Boolean_mvbdu.boolean_mvbdu_equiv
    let mvbdu_nimply = lift2 "line 94, bdd_nimply" Boolean_mvbdu.boolean_mvbdu_nimply 
    let mvbdu_nrev_imply = lift2 "line 95, bdd_nrev_imply" Boolean_mvbdu.boolean_mvbdu_nis_implied
    let mvbdu_bi_true = lift2 "line 96, bdd_bi_true" Boolean_mvbdu.boolean_constant_bi_true
    let mvbdu_bi_false = lift2 "line 97, bdd_bi_false" Boolean_mvbdu.boolean_constant_bi_false
    let mvbdu_fst parameters handler error a b = error,handler,a
    let mvbdu_snd parameters handler error a b = error,handler,b
    let mvbdu_nfst = lift2 "line 100, bdd_nfst" Boolean_mvbdu.boolean_mvbdu_nfst
    let mvbdu_nsnd = lift2 "line 101, bdd_nsnd" Boolean_mvbdu.boolean_mvbdu_nsnd 
    let mvbdu_redefine = lift2bis "line 102, bdd_redefine" Boolean_mvbdu.redefine  

    let build_list = lift1bis "line 181, build_list" List_algebra.build_list
      
    let build_sorted_list = lift1ter "line 181, build_list" List_algebra.build_sorted_list

    let build_reverse_sorted_list = lift1ter "line 181, build_list" List_algebra.build_reversed_sorted_list
      
    let print = Boolean_mvbdu.print_mvbdu
    let print_list = List_algebra.print_list 
  end: Mvbdu)

module Internalize(M:Mvbdu) = 
  (struct 
    module Mvbdu = M 
    type mvbdu = Mvbdu.mvbdu
    type hconsed_list = Mvbdu.hconsed_list 
    type handler = Mvbdu.handler 
    let handler = ref None 
    let parameter = ref (Remanent_parameters.get_parameters ())

  
    let check s error error' handler' = 
      let () = handler:= Some handler' in 
      if error'== error 
      then 
	()
      else 
	let error',() = 
	 Exception.warn !parameter error (Some "Mvbdu_wrapper.ml") (Some s)  Exit (fun () -> ())  
	in 
	Exception.print !parameter error' 

    let init parameters = 
      let error = Exception.empty_error_handler in 
      let error',output = M.init parameters error in 
      let () = parameter := parameters in 
      check "line 194, init" error error' output

    let is_init () = None != !handler 
    let equal = M.equal 
    let get_handler s error = 
      match 
	!handler 
      with 
      | None -> 
	let () = init !parameter in 
	let error',() = Exception.warn !parameter error (Some "Mvbdu_wrapper.ml") (Some (s^" uninitialised mvbdu"))  Exit (fun () -> ())  in 
	begin
	  match !handler with 
	  | None -> failwith "unrecoverable errors in bdu get_handler" 
	  | Some h -> error',h
	end
      | Some h -> error,h
    let lift_const s f = 
      let error = Exception.empty_error_handler in 
      let error',handler = get_handler s error in 
      let error',handler,mvbdu = f !parameter handler error' in 
      let _ = check s error error' handler in 
      mvbdu 
    let mvbdu_true ()  = lift_const "line 218, mvbdu_true" M.mvbdu_true
    let mvbdu_false () = lift_const "line 219, mvbdu_false" M.mvbdu_false

    let lift_unary s f x =
      let error = Exception.empty_error_handler in 
      let error',handler = get_handler s error in 
      let error',handler,mvbdu = f !parameter handler error' x in 
      let _ = check s error error' handler in 
      mvbdu


	
    let mvbdu_id = lift_unary "line 228, mvbdu_id" M.mvbdu_id
    let mvbdu_not = lift_unary "line 229, mvbdu_not" M.mvbdu_not

    let mvbdu_unary_true _ = mvbdu_true ()
    let mvbdu_unary_false _ = mvbdu_false ()
    let mvbdu_bi_true _ _ = mvbdu_true () 
    let mvbdu_bi_false _ _ = mvbdu_false ()
				
    let lift_binary s f x y =
      let error = Exception.empty_error_handler in 
      let error',handler = get_handler s error in 
      let error',handler,mvbdu = f !parameter handler error' x y in 
      let _ = check s error error' handler in 
      mvbdu
    let lift_binary' s f x y =
      let error = Exception.empty_error_handler in 
      let error',handler = get_handler s error in 
      let error',handler,mvbdu = f !parameter handler error' x y in 
      let _ = check s error error' handler in 
      mvbdu
    let mvbdu_and = lift_binary "line 243, mvbdu_and" M.mvbdu_and
    let mvbdu_or  = lift_binary "line 244, mvbdu_or" M.mvbdu_or
    let mvbdu_nand = lift_binary "line 245, mvbdu_nand" M.mvbdu_nand
    let mvbdu_nor = lift_binary "line 246, mvbdu_nor" M.mvbdu_nor
    let mvbdu_snd _ b = b			  
    let mvbdu_nsnd _ b = mvbdu_not b				
    let mvbdu_fst a _ = a
    let mvbdu_nfst a _ = mvbdu_not a
    let mvbdu_xor = lift_binary "line 251, mvbdu_xor" M.mvbdu_xor
    let mvbdu_nor = lift_binary "line 252, mvbdu_nor" M.mvbdu_nor
    let mvbdu_imply = lift_binary "line 253, mvbdu_imply" M.mvbdu_imply
    let mvbdu_nimply = lift_binary "line 254, mvbdu_nimply" M.mvbdu_nimply
    let mvbdu_rev_imply = lift_binary "line 255, mvbdu_imply" M.mvbdu_rev_imply
    let mvbdu_nrev_imply = lift_binary "line 256, mvbdu_nrev_imply" M.mvbdu_nrev_imply
    let mvbdu_equiv = lift_binary "line 256, mvbdu_nrev_imply" M.mvbdu_equiv
			       
				       
    let mvbdu_redefine = lift_binary "line 258, mvbdu_redefine" M.mvbdu_redefine

    let build_list = lift_unary "line 297" M.build_list 
    let build_sorted_list = lift_unary "line 298" M.build_sorted_list  
    let build_reverse_sorted_list = lift_unary "line 299" M.build_reverse_sorted_list 
    let print = M.print
    let print_list = M.print_list 
   end:Internalized_mvbdu)

module Optimize(M:Mvbdu) =
	 (struct
	     module Mvbdu = M
	     type handler = Mvbdu.handler 	      
	     type mvbdu = Mvbdu.mvbdu
	     type hconsed_list = Mvbdu.hconsed_list 
	     type 'output constant = 'output Mvbdu.constant
	     type ('input,'output) unary =  ('input,'output) Mvbdu.unary
	     type ('input1,'input2,'output) binary = ('input1,'input2,'output) Mvbdu.binary
										
  
	     let init = Mvbdu.init
	     let is_init = Mvbdu.is_init 
	     let equal = Mvbdu.equal
	     let equal_with_logs = Mvbdu.equal_with_logs
	     let mvbdu_nand  = Mvbdu.mvbdu_nand 
	     let mvbdu_not parameters handler error a = mvbdu_nand parameters handler error a a					       	      
	     let mvbdu_id = Mvbdu.mvbdu_id
	     let mvbdu_true = Mvbdu.mvbdu_true
	     let mvbdu_false = Mvbdu.mvbdu_false 
	     let mvbdu_unary_true parameters handler error a =
	       let error,handler,nota = mvbdu_not parameters handler error a in
	       mvbdu_nand parameters handler error a nota
	     let mvbdu_unary_false parameters handler error a =
	       let error,handler,mvtrue = mvbdu_unary_true parameters handler error a in
	       mvbdu_not parameters handler error mvtrue
	     let mvbdu_and parameters handler error a b =
	       let error,handler,ab = mvbdu_nand parameters handler error a b in
	       mvbdu_not parameters handler error ab
	     let mvbdu_or parameters handler error a b =
	       let error,handler,na = mvbdu_not parameters handler error a in
	       let error,handler,nb = mvbdu_not parameters handler error b in
	       mvbdu_nand parameters handler error na nb 
	     let mvbdu_imply parameters handler error a b =
	       let error,handler,notb = mvbdu_not parameters handler error b in
	       mvbdu_nand parameters handler error a notb
	     let mvbdu_rev_imply parameters handler error a b =
	       let error,handler,nota = mvbdu_not parameters handler error a in
	       mvbdu_nand parameters handler error nota b
	     let mvbdu_nor parameters handler error a b =
	       let error,handler,bddor = mvbdu_or parameters handler error a b in
	       mvbdu_not parameters handler error bddor 
	     let mvbdu_equiv parameters handler error a b =
	       let error,handler,direct = mvbdu_imply parameters handler error a b in
	       let error,handler,indirect = mvbdu_imply parameters handler error b a in
	       mvbdu_and parameters handler error direct indirect
	     let mvbdu_xor parameters handler error a b =
	       let error,handler,equiv = mvbdu_equiv parameters handler error a b in
	       mvbdu_not parameters handler error equiv
	     let mvbdu_nimply parameters handler error a b =
	       let error,handler,imply = mvbdu_imply parameters handler error a b in
	       mvbdu_not parameters handler error imply
	     let mvbdu_nrev_imply parameters handler error a b = mvbdu_nimply parameters handler error b a
	     let mvbdu_bi_true parameters handler error a _ = M.mvbdu_unary_true parameters handler error a
	     let mvbdu_bi_false parameters handler error a _ = M.mvbdu_unary_false parameters handler error a
	     let mvbdu_fst = M.mvbdu_fst
	     let mvbdu_snd = M.mvbdu_snd 
	     let mvbdu_nfst parameters handler error a _ = mvbdu_not parameters handler error a 
	     let mvbdu_nsnd parameters handler error _ a = mvbdu_not parameters handler error a						  
	     let mvbdu_redefine = M.mvbdu_redefine
	     let build_list = M.build_list 
	     let build_sorted_list = M.build_sorted_list
	     let build_reverse_sorted_list = M.build_reverse_sorted_list 
	     let print = M.print 
	     let print_list = M.print_list 
	   end:Mvbdu)

module Optimize'(M:Internalized_mvbdu) =
	 (struct
	     module Mvbdu = M
			      
	     type mvbdu = Mvbdu.mvbdu
	     type hconsed_list = Mvbdu.hconsed_list 
	    
	     let init = Mvbdu.init
	     let is_init = Mvbdu.is_init 
	     let equal = Mvbdu.equal
	     let mvbdu_nand a = Mvbdu.mvbdu_nand a 
	     let mvbdu_not a = mvbdu_nand  a a					       	      
	     let mvbdu_id = Mvbdu.mvbdu_id
	     let mvbdu_true = Mvbdu.mvbdu_true
	     let mvbdu_false = Mvbdu.mvbdu_false 
	     let mvbdu_unary_true a = mvbdu_nand a (mvbdu_not a)
	     let mvbdu_unary_false a = mvbdu_not (mvbdu_unary_true a) 
	     let mvbdu_and a b = mvbdu_not (mvbdu_nand a b) 
	     let mvbdu_or a b = mvbdu_nand (mvbdu_not a) (mvbdu_not b)
	     let mvbdu_imply a b = mvbdu_nand a (mvbdu_not b)
	     let mvbdu_rev_imply a b = mvbdu_imply b a 
	     let mvbdu_nor a b = mvbdu_not (mvbdu_or a b)
	     let mvbdu_equiv a b = mvbdu_and (mvbdu_imply a b) (mvbdu_imply b a)
	     let mvbdu_xor a b = mvbdu_not (mvbdu_equiv a b)
	     let mvbdu_nimply a b = mvbdu_not (mvbdu_imply a b)
	     let mvbdu_nrev_imply a b = mvbdu_nimply b a
	     let mvbdu_bi_true _ _ = M.mvbdu_true () 
	     let mvbdu_bi_false _ _ = M.mvbdu_false () 
	     let mvbdu_fst a _ = a
	     let mvbdu_snd _ b = b			      
	     let mvbdu_nfst a _ = mvbdu_not a 
	     let mvbdu_nsnd _ a = mvbdu_not a						  
	     let build_list = M.build_list 
	     let build_sorted_list = M.build_sorted_list
	     let build_reverse_sorted_list = M.build_reverse_sorted_list 
	     let mvbdu_redefine = M.mvbdu_redefine
	     let print = M.print
	     let print_list = M.print_list 
	   end:Internalized_mvbdu)

module Vd = struct end
module Mvbdu = Make(Vd)
module IntMvbdu = Internalize(Make (Vd))
module Optimized_Mvbdu = Optimize(Make(Vd))
module Optimized_IntMvbdu = Optimize'(Internalize(Make (Vd)))
				     

