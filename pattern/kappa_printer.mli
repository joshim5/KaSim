val lnk_t : Environment.t -> out_channel -> Mixture.lnk_t -> unit
val lnk_t_to_string : Environment.t -> unit -> Mixture.lnk_t -> string

val mixture : bool -> Environment.t -> out_channel -> Mixture.t -> unit
val mixture_to_string : bool -> Environment.t -> unit -> Mixture.t -> string