LIBDIR="$HOME/lib/bash"
CONFIGDIR="$HOME/.scripts"

sourcelib() {
    if ! source "$LIBDIR/$1.sh" 2>/dev/null; then
        echo "error: failed to load library $1" >&2
        exit 2
    fi
}
