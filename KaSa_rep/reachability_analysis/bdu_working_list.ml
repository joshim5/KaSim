(**
  * bdu_working_list.ml
  * openkappa
  * Jérôme Feret & Ly Kim Quyen, projet Abstraction, INRIA Paris-Rocquencourt
  * 
  * Creation: 2015, the 28th of October
  * Last modification: 
  * 
  * Compute the relations between sites in the BDU data structures
  * 
  * Copyright 2010,2011,2012,2013,2014 Institut National de Recherche en Informatique et   
  * en Automatique.  All rights reserved.  This file is distributed     
  * under the terms of the GNU Library General Public License *)

open Fifo
open Bdu_analysis_type
open Cckappa_sig

let warn parameters mh message exn default =
  Exception.warn parameters mh (Some "BDU fixpoint iteration") message exn
    (fun () -> default)  

let trace = false

(*----------------------------------------------------------------------------*)
(*working list content only creation rule_id: this is the initial working list*)

let collect_wl_creation parameter error rule_id rule store_result =
  List.fold_left (fun (error, store_result) (agent_id, agent_type) ->
    let error, agent = AgentMap.get parameter error agent_id rule.rule_rhs.views in
    match agent with
    | Some Dead_agent _
    | Some Unknown_agent _ 
    | None -> warn parameter error (Some "line 131") Exit store_result
    | Some Ghost -> error, store_result			     
    | Some Agent agent ->
       let error, wl = IntWL.push parameter error rule_id store_result in
       error, wl
  ) (error, store_result) rule.actions.creation
		 
