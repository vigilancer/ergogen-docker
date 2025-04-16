#!/usr/bin/env bash

main() {
  local pins=( VB GND C14 C13 C0 C15 C2 C1 A0 C3 A2 A1 A4 A3 A6 A5 C4 A7 B0 C5 B2 B1 B11 B10 P3V31 GND2 P3V32 GND3 P3V33 GND4 B9 GND5 B7 B8 B5 B6 B3 B4 C12 D2 C10 C11 A12 A15 A10 A11 A8 A9 C8 C9 C6 C7 B14 B15 B12 B13 P5V1 P5V2 GND6 GND7 NR TX RX GND8 P3V34 DIO CLK GND9 )

  for p in ${pins[@]}; do
    printf "${p}: {type: 'net', value:'${p}'},\n"
  done
}

main "$@"
