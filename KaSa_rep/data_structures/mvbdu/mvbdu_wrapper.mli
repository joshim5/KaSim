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
    val mvbdu_redefine:  mvbdu -> hconsed_list -> mvbdu
    val build_list: (int * int) list ->  hconsed_list 
    val build_sorted_list: (int * int) list -> hconsed_list
    val build_reverse_sorted_list: (int * int) list -> hconsed_list
    val print: out_channel -> string -> mvbdu -> unit 
    val print_list: out_channel -> string -> hconsed_list -> unit 
  end

module type Nul = 
  sig 
  end
module Make (M:Nul): Mvbdu 
module Mvbdu:Mvbdu
module IntMvbdu:Internalized_mvbdu
module Optimized_Mvbdu:Mvbdu
module Optimized_IntMvbdu:Internalized_mvbdu


