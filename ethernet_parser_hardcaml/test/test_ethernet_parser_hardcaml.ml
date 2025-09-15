open Hardcaml
open Ethernet_parser_hardcaml
(* helpers *)
(* let b1 x         = Bits.of_int ~width:1 x *)
let b16 x        = Bits.of_int ~width:16 x
let b48_i64 x    = Bits.of_int64 ~width:48 x
let b64_i64 x    = Bits.of_int64 ~width:64 x

let build_circuit () =
  let open Signal in
  let clk    = input "clk" 1 in
  let tdata  = input "tdata" 64 in
  let tvalid = input "tvalid" 1 in
  let i : Signal.t Parser.I.t = { clk; tdata; tvalid } in
  let o : Signal.t Parser.O.t = Parser.Parser.create i in
  Circuit.create_exn ~name:"ethernet_header_parser"
    [ output "dst_mac"  o.dst_mac
    ; output "src_mac"  o.src_mac
    ; output "eth_type" o.eth_type
    ; output "valid"    o.valid
    ]
;;

let () =
  let open Hardcaml.Cyclesim in
  let sim     = create (build_circuit ()) in
  let i_clk   = Hardcaml.Cyclesim.in_port  sim "clk" in
  let i_data  = Hardcaml.Cyclesim.in_port  sim "tdata" in
  let i_vld   = Hardcaml.Cyclesim.in_port  sim "tvalid" in
  let o_dst   = Hardcaml.Cyclesim.out_port sim "dst_mac" in
  let o_src   = Hardcaml.Cyclesim.out_port sim "src_mac" in
  let o_type  = Hardcaml.Cyclesim.out_port sim "eth_type" in
  let o_valid = Hardcaml.Cyclesim.out_port sim "valid" in

  let tick () =
    i_clk := Bits.vdd;  cycle sim;
    i_clk := Bits.gnd;  cycle sim
  in

  (* --- Test vector ---
     Frame header:
       Dst MAC   = 11:22:33:44:55:66
       Src MAC   = AA:BB:CC:DD:EE:FF
       EtherType = 0x0800 (IPv4)
     Cycle 0 word = B7..B0 = BBAA665544332211
     Cycle 1 word = B15..B8 = DEAD0008FFEEDDCC  (B14/B15 payload start)
  *)
  let w0 = b64_i64 0xBBAA665544332211L in
  let w1 = b64_i64 0xDEAD0008FFEEDDCCL in

  let exp_dst = b48_i64 0x00112233445566L in
  let exp_src = b48_i64 0x00AABBCCDDEEFFL in
  let exp_typ = b16 0x0800 in

  (* initial begin from verilog *)
  i_clk  := Bits.gnd;
  i_vld  := Bits.gnd;
  i_data := Bits.zero 64;
  tick ();

  (* cycle 0 *)
  i_vld  := Bits.vdd;
  i_data := w0;
  tick ();

  (* cycle 1 *)
  i_data := w1;
  tick ();

  (* cycle 3, we should ignore the noise*)
  i_data := b64_i64 0x1122334455667788L;
  tick (); 

  (* gap between frames *)
  i_vld  := Bits.gnd;
  i_data := Bits.zero 64;
  tick ();

  let show b = Bits.to_string b in
  Printf.printf "dst_mac  = %s\nsrc_mac  = %s\neth_type = %s\nvalid    = %s\n%!"
    (show !o_dst) (show !o_src) (show !o_type) (show !o_valid);

 let assert_eq name got exp =
  if not (Bits.equal got exp) then begin
    Printf.eprintf "ASSERT FAIL %s: got %s expected %s\n%!"
      name (show got) (show exp);
    exit 1
  end
  in

  assert_eq "dst_mac"  !o_dst  exp_dst;
  assert_eq "src_mac"  !o_src  exp_src;
  assert_eq "eth_type" !o_type exp_typ;

  Printf.printf "All tests passed.\n%!"