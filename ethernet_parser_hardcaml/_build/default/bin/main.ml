open Hardcaml
open Ethernet_parser_hardcaml
let () =
  let open Signal in
  let clk    = input "clk" 1 in
  let tdata  = input "tdata" 64 in
  let tvalid = input "tvalid" 1 in

  let i  : Signal.t Parser.I.t = { clk; tdata; tvalid } in
  let o  : Signal.t Parser.O.t = Parser.Parser.create i in
  let outs =
    [ output "dst_mac"  o.dst_mac
    ; output "src_mac"  o.src_mac
    ; output "eth_type" o.eth_type
    ; output "valid"    o.valid
    ]
  in

  let circuit = Circuit.create_exn ~name:"ethernet_header_parser" outs in
  Rtl.print Verilog (circuit)
  
