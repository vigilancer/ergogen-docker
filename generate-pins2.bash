#!/usr/bin/env bash

main() {
  local pins=( NC1 NC2 NC3 NC4 NC5 NC6 NC7 NC8 NC9 NC10 NC11 NC12 NC13 NC14 NC15 NC16 NC17 NC18 NC19 NC20 NR1 NR2 NR3 NR4 NR5 NR6 NR7 NR8 NE1 NE2 NE3 NE4 )

  for p in ${pins[@]}; do
    printf "${p}: {type: 'net', value:'${p}'},\n"
  done
}

main "$@"
