
__update_footprints_gui() {
  ./fetch-footprints.sh ../ergogen-footprints/my/ ../ergogen-footprints/vanilla/ --clear
  ./make-gui.sh sync
}

__generate_pcb() {
  ./fetch-footprints.sh ../ergogen-footprints/my/ ../ergogen-footprints/vanilla/ --clear && \

  ./make-cli.sh run && \

  open output/pcbs/clavier.kicad_pcb
}

__watch_and_gen_pcb() {
  find input/ | entr -p bash -c "pkill pcbnew; source env.sh && __generate_pcb"
}


alias ff=__update_footprints_gui
alias gg=__generate_pcb

alias rgg=__watch_and_gen_pcb



alias d=docker

