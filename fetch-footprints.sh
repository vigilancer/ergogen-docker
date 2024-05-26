#!/usr/bin/env bash

[ -z $DEBUG ] || set -x
set -eu -o pipefail

usage="

Footprints downloader.
Fetches footprint files from different sources into one local directory.

$(basename "$0") -h

$(basename "$0") -i [DIR]

$(basename "$0") [-o OUTOUT] [--add-vanilla] [--clear] [SOURCE .. ]

"


help="

Tool can fetch footprints from git repo, local directory or from official ergogen github repo.
It will download vanilla footprints from ergogen repo if --add-vanilla is specified.
Also it will update index.js to include all acquired footprints.

Original purpose of this tool was to simplify running ergogen in Docker when 'footprints' folder
mount into container running cli ergogen so it would be possible to use custom not vanilla footprints
that comes bundled with ergogen package.
Same scenario is possible with ergogen-gui running in Docker to preview custom footprints.

But one can find other use for different scenarios for this tool.

  -h              - Help (short)

  --help          - Help (extended)

  -i DIR          - Only update index.js inside DIR.
                    No footprints will be downloaded.
                    Existing footprints inside DIR (non-recursive) will be used.
                    Resulting index.js will be created inside DIR.
                    Existing index.js will be overriden.
                    When DIR is missing default 'footprints/' will be used.

  -o OUTPUT       - Where to place all downloaded footprints and resulting index.js.
                    index.js will be created afresh from all .js files in OUTPUT.
                    Existing index.js will be overriden.
                    If directory does not exists it will be created.

  --clear    - Clear OUTPUT dir before downloading footprints.
                    By default if OUTPUT directory exists we stop.

  --add-vanilla  - Download vanila footprints from ergogen repo.
                    By default vanilla footprints from ergogen repo will NOT be downloaded without explicit request.

  SOURCE            List of sources where to acquire footprints.
                    If no SOURCE are specified and --add-vanilla not specified nothing will be downloaded and --clear will be ignored.
                    If no SOURCE are specified and --add-vanilla is specified only vanilla ergogen footprints will be downloaded.
                    If no SOURCE are specified index.js will not be updated because vanilla footprints folder already contains valid one.

  When multiple SOURCEs are specified they will be merged into single OUTPUT directory.
  In case of collision (two or more footprint files with same name) only one of them will be left in OUTPUT directory.
  No guarantees are given on order of downloading SOURCES and as result on order of overriding files during collision
  other than vanilla official ergogen footprints will always be downloaded first (if --add-vanilla was  specified).

  This tools is trying to be intelligent in interpretation of what SOURCE can possibly be.
  You can speficy following things as SOURCE:

  local directory
  - all .js files in root of directory will be used (non-recursive)

  git repo
  - Footprints from any git repo can be downloaded.
    In this case SOURCE is expected to use syntax that is suitable to feed directly into 'git' command.
    Additionally tool supports syntax to specify exact directory in repo where to look for footprints.
    To specify directory add # and folder path relative to root of repo (for example '#src/footprints' for vanilla ergogen repo).
    See EXAMPLES below.


  EXAMPLES:

  Update index.js:

  $(basename "$0") -i ./footprints


  Download vanilla footprints (index.js will be downloaded from ergogen repo and will not be generated)
  into default 'footprints' in current directory. 'footprints' will be created if missing.

  $(basename "$0")
  

  Use only locally stored footprints:

  $(basename "$0") -o ./footprints SOME_DIR_WITH_FOOTPRINTS/


  Download vanilla footprints (index.js will be downloaded from ergogen repo and will not be generated):

  $(basename "$0") -o ./footprints --add-vanilla 


  Download external footprints from github:

  $(basename "$0") -o ./footprints "https://github.com/ceoloide/ergogen-footprints.git"


  Download external footprints with custom path inside repo (src/footprints):

  $(basename "$0") -o ./footprints "https://github.com/ergogen/ergogen.git#src/footprints" 

"

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

do_help() {
  echo "$usage"
  exit 0
}

do_error() {
  local text="$1"; shift
  local code="$1"; shift

  echo "$text"

  exit code
}

validate_args() {
  local output="$1"; shift
  local add_vanilla="$1"; shift
  local do_clear="$1"; shift
  local update_index_only="$1"; shift
  local sources=("$@")

  if [ $update_index_only -eq 1 ]; then
    [ ! -z $output ] || err "DIR is not set for -i" 12
  fi

  if [ ${#sources[@]} -gt 0 ] && [ -z "$output" ]; then
    err "Output should be set with -o" 22
  fi

}

do_update_index() {
  local dir="$1"
  local index="index.js"
  [ -d "$dir" ] || err "Directory "$dir" does not exist" 98
  m "Updating index $dir/$index ..."

  cd "$dir"
  [ -f "$index" ] && rm "$index"

  echo "module.exports = {" >> "$index"

  for f in $(find . -name "*.js"); do
    echo $f
    [ -f "$f" ] || continue
    local mfile=$(echo $f | perl -pe 's/.js$//')
    local mname=$(echo $mfile | perl -pe 's/^\.\///' | perl -pe 's/\//:/')

    [ "$mfile" != "index" ] || continue
    echo "    \"$mname\": require('$mfile')," >> "$index"
  done

  echo "}" >> "$index"
  cd -
  m "Done updating"
}

do_process_source() {
  local src="$1"; shift
  local out="$1"; shift

  out=$(cd "$out"; pwd)
  m "Processing $src into $out ..."

  # process local dir
  if [ -d "$src" ]; then
    src=$(cd $src; pwd)
    cd "$src"
    find . -name "*.js" | cpio -p -dumv "$out/"
    cd -
  else
    local src_arr=()
    IFS='#' read -ra src_arr <<< "$src"

    local url="${src_arr[0]}" 
    local path="/"
    [ ${#src_arr[@]} -gt 1 ] && path="${src_arr[1]}"

    if $(git ls-remote -q --exit-code "$url" >/dev/null); then
      m "url: $url"
      m "path: $path"

      local tmpdir=$(mktemp -d -t ergogen)
      git clone "$url" "$tmpdir/"

      # remove first leading /
      path=$(echo $path | perl -pe 's/^\///')

      cd "$tmpdir/$path/" 
      cp *.js "$out/"
      cd -
    fi
  fi

  m "Done processing"
}

__process_git_src() {
  local repo="$1"; shift
  local path="$1"; shift
}

main() {
  local output="footprints"
  local add_vanilla=0
  local do_clear=0
  local update_index_only=0
  local sources=()

  while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i) 
        {
          update_index_only=1; 
          if [ $# -ge 2 ]; then
            output="$2"
            shift
          fi
        } ;;
        -h) echo "$usage"; exit 0;;
        --help) echo "$usage" echo "$help"; exit 0;;
        -o) output="$2"; shift ;;
        --add-vanilla) add_vanilla=1 ;;
        --clear) do_clear=1 ;;
        # *) do_error "Unknown parameter passed: $1" 127 ;;
        *) sources+=( "$1" ) ;;
    esac
    shift
  done

  m ""
  m "Output dir: $output"
  m ""
  local t=$([ $add_vanilla -eq 1 ] && echo "True" || echo "False")
  m "Adding vanilla: $t"
  local t=$([ $do_clear -eq 1 ] && echo "True" || echo "False")
  m "Clear output dir: $t"
  local t=$([ $update_index_only -eq 1 ] && echo "True" || echo "False" )
  m "Update index only: $t"
  m ""

  if [ $update_index_only -eq 1 ]; then
    do_update_index "$output"
    exit 0
  fi

  if [ $add_vanilla -eq 1 ]; then
    local tmp=( "https://github.com/ergogen/ergogen.git#src/footprints" )
    tmp += "${sources[@]}"
    sources=($tmp)
  fi

  if [ -d "$output" ] && [ $do_clear -eq 0 ]; then
    err "Output $output already exists and no --clear provided. Exiting ..." 99
  fi

  [ -d "$output" ] || {
    m "Creating $output ..."
    mkdir "$output"
    m "Done creating"
  }

  output=$(cd "$output"; pwd)

  validate_args "$output" "$add_vanilla" "$do_clear" "$update_index_only" "${sources[@]}"

  m ""
  m "Using these sources:"
  for s in ${sources[@]}; do
    m "$s"
  done
  m ""

  if [ $do_clear -eq 1 ]; then
    m "Clearing output $output ..."
    rm -rf "$output/"*
    m "Done clearing"
  fi

  for src in ${sources[@]}; do
    do_process_source "$src" "$output"
  done

  # update indexes if one of these is true:
  # (both conditions make sure that at least one custom source is specified)
  # = --add-vanilla and size(sources) > 1
  # = no --add-vanilla and size(sources) > 0
  if [ $add_vanilla -eq 1 ] && [ ${#sources[@]} -gt 1 ]; then
    do_update_index "$output"
  fi
  if [ $add_vanilla -eq 0 ] && [ ${#sources[@]} -gt 0 ]; then
    do_update_index "$output"
  fi

}

main "$@"
