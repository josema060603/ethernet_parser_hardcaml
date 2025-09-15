open Hardcaml
(* Input is a high speed protocol, in this case AXI-stream (tlast is ignored, as this is only the parser) *)
module I = struct
  type 'a t = {
    clk : 'a ;
    tdata  : 'a [@bits 64];   (* 64-bit input bus *)
    tvalid : 'a;              (* valid flag *)
  } [@@deriving hardcaml]
end
(* Output is data ready to be decoded by the device, valid is up until transaction is finished *)

module O = struct
  type 'a t = {
    dst_mac  : 'a [@bits 48];
    src_mac  : 'a [@bits 48];
    eth_type : 'a [@bits 16];
    valid    : 'a;
  } [@@deriving hardcaml]
end

module Parser = struct
    let create (i : _ I.t) : _ O.t =
    (* let open Signal in *)
    let spec = Reg_spec.create ~clock:i.clk () in
    let idle : Signal.t = Signal.of_int ~width:2 0 in
    let r1   : Signal.t = Signal.of_int ~width:2 1 in
    let r2   : Signal.t = Signal.of_int ~width:2 2 in 
    let send : Signal.t = Signal.of_int ~width:2 3 in 
    let state =
    Signal.reg_fb spec ~width:2 ~f:(fun d ->
    Signal.mux d [
      Signal.mux2 i.tvalid r1 idle;
      Signal.mux2 i.tvalid r2 r1;
      Signal.mux2 i.tvalid send r2;
      Signal.mux2 i.tvalid send idle
    ]) in
    let dst_mac = Signal.reg_fb spec ~width:48  ~f:(fun d -> 
      Signal.mux state [ 
        d; 
        Signal.select i.tdata 47 0;
        d;
        d
        ]) in
    let src_mac = Signal.reg_fb spec ~width:48  ~f:(fun d -> 
      Signal.mux state [ 
        d; 
        Signal.concat_msb[Signal.select d 47 16 ; Signal.select i.tdata 63 48];
        Signal.concat_msb[Signal.select i.tdata 31 0; Signal.select d 15 0];
        d
        ]) in
    let eth_type = Signal.reg_fb spec ~width:16 ~f:(fun d -> 
      Signal.mux state [ 
        d; 
        d;
        Signal.select i.tdata 47 32;
        d
        ]) in
    let valid = Signal.reg_fb spec ~width:1 ~f:(fun _ -> 
      Signal.mux state [ 
        Signal.of_int ~width:1 0; 
        Signal.of_int ~width:1 0; 
        Signal.of_int ~width:1 0; 
        Signal.of_int ~width:1 1
        ]) in

    { O.dst_mac = dst_mac;
  O.src_mac = src_mac;
  O.eth_type = eth_type;
  O.valid = valid }

end

