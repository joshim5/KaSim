(**
  * bdu_fixpoint_iteration.ml
  * openkappa
  * Jérôme Feret & Ly Kim Quyen, projet Abstraction, INRIA Paris-Rocquencourt
  * 
  * Creation: 2015, the 9th of October
  * Last modification: 
  * 
  * Compute the relations between sites in the BDU data structures
  * 
  * Copyright 2010,2011,2012,2013,2014 Institut National de Recherche en Informatique et   
  * en Automatique.  All rights reserved.  This file is distributed     
  * under the terms of the GNU Library General Public License *)

open Cckappa_sig
open Bdu_analysis_type
open SetMap
open Mvbdu_sig
open Boolean_mvbdu
open Memo_sig
open Site_map_and_set
open Covering_classes_type
open Bdu_build_common

(************************************************************************************)
(*fixpoint iteration function*)
(*from an array of rule, build bdu:{of creation rule; test; list of modification}.
  the idea of iterate function: 
  - if working list is empty then return the bdu_remanent_array;
  - pop the first element inside the working list;
  - get 'rule' type from the rule_array;
  - build bdu_creation; bdu_test, and a list of action;
  - build a list of type List_sig.list for modif_list (list of action);
  - check if it  is an enable rule or not:
    it is an enable rule if the result of intersection of test and init is not empty;
    + if it is an enable rule return the result.
    + if it is not an enable rule: call iterate update function:
      ++ bdu_creation intersection (mvbdu_and) with bdu_test, 
         then use the result above: redefine (redefine function in mvbdu) it
         with the list of modif;
      ++ do the union (mvbdu_or) of bdu_assignment (the intersection above) and bdu_creation;
      ++ store this bdu_update in bdu_array, with the index is rule_id.
*)

(************************************************************************************)
(*is enable rule*)

let is_belong bdu bdu_init =
  let is_eq = Mvbdu_sanity.safety_equal_mvbdu bdu bdu_init in
  if is_eq
  then true
  else false
    
let comp_is_enable parameter error handler bdu_init bdu_test bdu_creation =
  let error, handler, bdu_X =
    f parameter error bdu_test
      (boolean_mvbdu_and parameter handler error parameter bdu_test) bdu_creation
  in
  if not (is_belong bdu_X bdu_init)
  then
    error, true
  else
    error, false

(************************************************************************************)
(*update bdu*)

let compute_update parameter error rule_id handler bdu_test modif_list bdu_creation
    bdu_remanent_array =
  let error, handler, bdu_inter_test_creation =
    f parameter error bdu_test
      (boolean_mvbdu_and parameter handler error parameter bdu_test) bdu_creation
  in
  let error, handler, bdu_assigment =
    f parameter error bdu_inter_test_creation
      (redefine parameter error parameter handler bdu_inter_test_creation)
      modif_list
  in
  let error, handler, bdu_update =
    f parameter error bdu_assigment
      (boolean_mvbdu_or parameter handler error parameter bdu_assigment)
      bdu_creation
  in
  let bdu_remanent_array =
    bdu_remanent_array.(rule_id) <- bdu_update;
    bdu_remanent_array
  in
  error, bdu_remanent_array
    
(************************************************************************************)
(*function mapping a list of covering class, return triple
  (list of new_index, map1, map2)
  For example:
  - intput : covering_class_list [0;1]
  - output : 
  {new_index_of_covering_class: [1;2],
  map1 (from 0->1, 1->2),
  map2 (from 1->0, 2->1)
  }
*)

let new_index_pair_map parameter error l =
  let rec aux acc k map1 map2 =
    match acc with
    | [] -> error, (map1, map2)
    | h :: tl ->
      let error, map1 =
        add_map parameter error h k map1
      in
      let error, map2 =
        add_map parameter error k h map2
      in
      aux tl (k+1) map1 map2
  in aux l 1 empty_map empty_map

(************************************************************************************)
(*convert a list to a set*)

let list2set parameter error list =
  List.fold_left (fun (error, current_set) elt ->
    let add_set =
      Set.add elt current_set
    in
    error, add_set
  ) (error, Set.empty) list

(************************************************************************************)
(* From each covering class, with their new index for sites, build 
   (bdu_test, bdu_creation and list of modification).
   Note: not taking sites in the local, because it will be longer.
   - Convert type set of sites into map restriction
*)

let collect_remanent_test parameter error rule store_remanent store_result =
  AgentMap.fold2_common parameter error 
    (fun parameter error agent_type remanent agent store_result ->
      match agent with
      | Ghost -> error, store_result
      | Agent agent ->
        let agent_type_test = agent.agent_name in
        (*get store_dic*)
        let store_dic = remanent.store_dic in
        (*restriction map*)
        let error, triple_list =
          Dictionary_of_Covering_class.fold
            (fun list _ id (error, current_list) ->
              (*-------------------------------------------------------------------*)
              (*convert a list of a covering class into a set*)
              let error, set = list2set parameter error list in
              (*-------------------------------------------------------------------*)
              (*get the next_set*)
              let new_set = (id, list, set) :: current_list in
              error, List.rev new_set
            ) store_dic (error, [])
        in
        (*-------------------------------------------------------------------------*)
        (*store*)
        let error, store_result =
          AgentMap.set
            parameter
            error
            agent_type_test
            triple_list
            store_result
        in
        error, store_result
    ) store_remanent rule.rule_lhs.views store_result

(************************************************************************************)

let collect_test_restriction parameter error rule store_remanent_test store_result =
  AgentMap.fold2_common parameter error
    (fun parameter error agent_type agent triple_list store_result ->
      match agent with
      | Ghost -> error, store_result
      | Agent agent ->
        let agent_type_test = agent.agent_name in
        let error, pair_list =
          List.fold_left (fun (error, current_list) (id, list, set) ->
            (*-----------------------------------------------------------------*)
            let error, (map_new_index_forward, _) =
              new_index_pair_map parameter error list
            in
            (*-----------------------------------------------------------------*)
            let error, map_res =
              Site_map_and_set.Map.monadic_fold_restriction parameter error
                (fun paramaters error site port store_result ->
                  let state = port.site_state.min in
                  (*-----------------------------------------------------------*)
                  (*search new_index of site inside a map forward*)
                  let site' =
                    Site_map_and_set.Map.find_default
                      0 site map_new_index_forward in
                  (*-----------------------------------------------------------*)
                  (*add this new_index site into a map restriction*)
                    error,Site_map_and_set.Map.add
                      site'
                      state
                      store_result
                ) set agent.agent_interface Site_map_and_set.Map.empty
            in
            error, ((id, map_res) :: current_list)
          ) (error, []) triple_list
        in
        (*-----------------------------------------------------------------*)
        (*get old*)
        let error, old_pair =
          match AgentMap.unsafe_get parameter error agent_type_test store_result with
          | error, None -> error, []
          | error, Some l -> error, l
        in
        let new_pair_list = List.concat [pair_list; old_pair] in
        (*-----------------------------------------------------------------*)
        let error, store_result =
          AgentMap.set
            parameter
            error
            agent_type_test
            new_pair_list
            store_result
        in
        error, store_result
    ) rule.rule_lhs.views store_remanent_test store_result

(************************************************************************************)

let collect_bdu_test parameter error store_test_restriction store_result =
  let error, (handler, bdu_init) = bdu_init parameter error in
  AgentMap.fold parameter error
    (fun parameter error agent_type pair_list store_result ->
      (*build bdu test*)
      let error, list =
        List.fold_left (fun (error, store_list) (id, map_res) ->
          let error, (l, (handler, bdu_test)) =
            Site_map_and_set.Map.fold
              (fun site' state (error, (current_list, _)) ->
                let p = (site', state) :: current_list in
                let error, (handler, bdu_test) =
                  build_bdu parameter error p
                in
                error, (p, (handler, bdu_test))
              ) map_res (error, ([], (handler, bdu_init)))
          in
          (*store in an array*)
          error, ((l, id, (handler, bdu_test)) :: store_list)
        ) (error, []) pair_list
      in
      (*store*)
      let error, store_result =
        AgentMap.set
          parameter
          error
          agent_type
          (List.rev list)
          store_result
      in
      error, store_result
    ) store_test_restriction store_result