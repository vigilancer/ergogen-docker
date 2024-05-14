
__update_footprints() {
  ./fetch-footprints.sh --skip-vanilla ../ergogen-footprints/vanilla/ ../ergogen-footprints/
  ./make-gui.sh sync
}

alias ff=__update_footprints

alias d=docker

