
__update_footprints() {
  ./fetch-footprints.sh ../ergogen-footprints/my/ ../ergogen-footprints/vanilla/ --clear
  ./make-gui.sh sync
}

alias ff=__update_footprints

alias d=docker

