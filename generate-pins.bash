#!/usr/bin/env bash

main() {
  local pins=(B12 B13 B14 B15 A8 A9 A10 A11 A12 A15 B3 B4 B5 B6 B7 B8 B9 POW_5V_1 GND_1 POW_3V3_1  VB C13 C14 C15 R A0 A1 A2 A3 A4 A5 A6 A7 B0 B1 B2 B10 POW_3V3_2 GND_2 POW_5V_2 POW_3V3_3 SWDIO SWSCK GND_3 )

  for p in ${pins[@]}; do
    printf "${p}: {type: 'net', value:'${p}'},\n"
  done
}

main "$@"
