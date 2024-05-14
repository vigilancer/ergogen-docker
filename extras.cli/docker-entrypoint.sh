
main() {
    echo "Rebuilding ergogen with new footprints"
    npm run --prefix=/usr/local/lib/node_modules/ergogen/ build

    if [ $# -gt 0 ]; then
        ergogen "$@"
    else
        ergogen /work/input/keyboard.yaml --clean --debug --output=/work/output
    fi
}

main "$@"