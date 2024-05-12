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
    local target="${1-run}"
    docker build \
        --no-cache \
        --target "${target}"  \
        -t ergogen-cli:latest \
        -f Dockerfile.cli \
        .
}

ergogen_run() {
    local args="${1:-}"
    local cmd="
    docker run \
        -it \
        --rm \
        --init \
        --name ergogen-cli \
        -v $(pwd)/footprints:/usr/local/lib/node_modules/ergogen/src/footprints \
        -v $(pwd)/input:/work/input \
        -v $(pwd)/output:/work/output \
        ergogen-cli:latest
    "

    [ ! -z "$args" ] && cmd="$cmd $args"
    
    $cmd
}

main() {
    [ $# -eq 0 ] && err "available subcommands: build, run" 2

    local cmd="$1"; shift

    case $cmd in
        "build" | "run")
        $"ergogen_$cmd" "$@"
        ;;
        *)
        err "command $cmd is not supported" 3
        ;;
    esac
}

main "$@"