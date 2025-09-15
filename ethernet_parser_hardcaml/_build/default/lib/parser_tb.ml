(* open Hardcaml
open Hardcaml_waveterm

let test () =
  let module Sim = Cyclesim in
  let sim, waves =
    Sim.create (Parser.create (Scope.create ())) in
  (* TODO: drive inputs with sample Ethernet frame *)
  Waveform.print waves

let () = test () *)
