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
(* Assuming Big Ending DMA *)
module Parser = struct
    let create (i : _ I.t) : _ O.t =
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
      Signal.mux state [ (* destination B0:B1:B2:B3:B4:B5*)
        d; 
        Signal.concat_msb [ 
        Signal.select i.tdata 7 0;    (* B0*)
        Signal.select i.tdata 15 8;   (* B1*)
        Signal.select i.tdata 23 16;  (* B2*)
        Signal.select i.tdata 31 24;  (* B3*)
        Signal.select i.tdata 39 32;  (* B4*)
        Signal.select i.tdata 47 40;  (* B5*)];
        d;
        d
        ]) in
    let src_mac = Signal.reg_fb spec ~width:48  ~f:(fun d -> 
      Signal.mux state [ (* source B6:B7:B8:B9:B10:B11*)
        d; 
        Signal.concat_msb [
        Signal.select i.tdata 55 48;  (* B6*)
        Signal.select i.tdata 63 56;  (* B7*)
        Signal.zero 32;];
      Signal.concat_msb [
      Signal.select d 47 32;        (* B6 B7 captured in r1 *)
      Signal.select i.tdata 7 0;    (* B8*)
      Signal.select i.tdata 15 8;   (* B9*)
      Signal.select i.tdata 23 16;  (* B10*)
      Signal.select i.tdata 31 24;  (* B11*)];
        d
        ]) in
    let eth_type = Signal.reg_fb spec ~width:16 ~f:(fun d -> 
      Signal.mux state [ (* ethernet type B12B13*)
        d; 
        d;
        Signal.concat_msb [
        Signal.select i.tdata 39 32;  (* B12*)
        Signal.select i.tdata 47 40;  (* B13*)];
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

