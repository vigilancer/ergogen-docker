#!/usr/bin/env bash

set -eu -o pipefail
[ -z ${DEBUG-} ] || set -x

m() {
  ## Usage# m "$MESSAGE"
  printf "[- INFO --- ] $1\n"
}

err() {
  ## Usage (w exit)  # mkdir "$DIR" || err 'cannot create dir' 1
  ## Usage (wo exit) # mkdir "$DIR" || err 'cannot create dir'
  local message="$1"; shift
  local exit_code="$1"; shift

  [ -n "$message" ] && printf "[- ERR ---- ] $message\n" >&2
  [ -n "$exit_code" ] && exit "$exit_code"
}

ergogen_build() {
    local target="${1:-run}"
    docker build \
        --target "${target}"  \
        -t ergogen-gui:latest \
        -f Dockerfile.gui \
        .
}

ergogen_run() {
    docker run \
        -it \
        --rm \
        --init \
        --name ergogen-gui \
        -p 3000:3000 \
        -v $(pwd)/footprints:/ergogen-gui/node_modules/ergogen/src/footprints \
        ergogen-gui:latest
}

ergogen_daemon() {
    docker run \
        -d \
        --rm \
        --init \
        --name ergogen-gui \
        -p 3000:3000 \
        -v $(pwd)/footprints:/ergogen-gui/node_modules/ergogen/src/footprints \
        ergogen-gui:latest
}

main() {
    [ $# -eq 0 ] && err "available subcommands: build, run, daemon" 2

    local cmd="$1"; shift

    case $cmd in
        "build" | "run" | "daemon")
        $"ergogen_$cmd" "$@"
        ;;
        *)
        err "command $cmd is not supported" 3
        ;;
    esac
}

main "$@"