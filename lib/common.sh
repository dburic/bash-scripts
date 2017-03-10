# common.sh - common functions for shell programs

# Program's basename and realpath
PROGNAME=$(basename "$0")
REALPATH=$(realpath "$0")

# Should messages begin with the program's name? 0 = false, everything else = true
PRINTNAME=0

# Print a message to stderr
printmsg() {
    [ "$PRINTNAME" -ne 0 ] && echo -n "$PROGNAME: " >&2
    echo "$1" >&2
}

# Print a warning
warn() {
    printmsg "warning: $1"
}

# Error handling routines

# Array of error messages
ERRORMSGS=()

# Add error messages
adderrormsgs() {
    local code msg
    while [ $# -ge 2 ]; do
        code=${1//\'/\'\\\'\'}
        msg=${2//\'/\'\\\'\'}
        ERRORMSGS+=("'$code' '$msg'") 
        shift 2
    done
    if [ $# -ne 0 ]; then
        printmsg "error: $FUNCNAME needs an even number of arguments"
        exit 1
    fi
}

# Default error messages
adderrormsgs \
    SIGTERM    'program terminated' \
    SIGINT     'program interrupted by user' \
    INVOPT     'invalid option, try --help' \
    MISSOPT    'missing option %s' \
    UNPROCOPT  'oops, unprocessed option %s' \
    INVVAL     'invalid value %s' \
    MISSVAL    'option %s requires a value' \
    MISSARG    'missing required argument' \
    INVARG     'invalid argument %s' \
    NODO       'nothing to do' \
    RC         'error in config file %s' \
    CHILD      '%s exited with non-zero status' \
    EXISTS     '%s already exists' \
    NOTEXIST   '%s does not exist' \
    NOTFILE    '%s does not exist or is not a regular file' \
    NOTDIR     '%s is not a directory' \
    TEMPFILE   'cannot create temporary file' \
    MKFILE     'cannot create file %s' \
    MKDIR      'cannot create directory %s' \
    RMFILE     'cannot remove file %s' \
    RMDIR      'cannot remove directory %s' \
    MOUNTED    '%s is already mounted' \
    NOTMOUNTED '%s is not mounted' \
    OTHER      '%s'

# Return error message given its code
errormsg() {
    local code="$1" e
    for e in "${ERRORMSGS[@]}"; do
        eval set -- "$e"
        if [ "$1" = "$code" ]; then
            echo "$2"
            return
        fi
    done
    echo "unknown error code $code"
}

# Exit due to error
errorexit() {
    local code="$1" msg
    shift
    printf -v msg "$(errormsg "$code")" "$@"
    printmsg "error: $msg"
    exit 1
}

# This should probably be redefined
showhelp() {
    cat <<EOF
Use the source, Luke! ;)
EOF
}

# Is $1 an integer?
isint() {
    printf "%d" "$1" >/dev/null 2>&1
}

# Nonnegative integer?
isnnint() {
    isint "$1" && [ "$1" -ge 0 ]
}

# Positive integer?
ispsint() {
    isint "$1" && [ "$1" -gt 0 ]
}

# Is $1 a float?
isfloat() {
    printf "%e" "$1" >/dev/null 2>&1
}

# Nonnegative float?
isnnfloat() {
    isfloat "$1" && (printf "%e" "$1" | grep -q '^[0-9]')
}

# Positive float?
ispsfloat() {
    isfloat "$1" && (printf "%e" "$1" | grep -q '^[1-9]')
}

# Is $1 equal to one of $2, $3, $4, ...?
inlist() {
    local v0="$1"
    local v
    shift
    for v; do 
        [ "$v0" = "$v" ] && return 0
    done
    return 1
}

# Check that argument is in the NUMBER[SUFFIX] format that can be passed to
# the sleep command
issleepdelay() {
    echo "$1" | grep -q -E '^[0-9]*\.?[0-9]+[smhd]?$'
}

# Is device or directory $1 already mounted?
ismounted() {
    mount | grep -q -E "(^$1 | on $1 )"
}

# Is $1 a function?
isfunction() {
    [ "$(type -t "$1")" = "function" ]
}

# Is $1 an executable file?
isexecutable() {
    if [ -x "$1" ]; then
        return 0 
    elif which "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Join $1, $2, ... with / and remove extra /'s; empty arguments are ignored
joinpaths() {
    local p r=""
    for p; do
        [ -z "$p" ] && continue
        [ -n "$r" ] && r+="/$p" || r="$p"
    done
    echo "$r" | perl -p -e 's{/+}{/}g'
}

# Return extension of $1 if it has one, otherwise return nothing
fileext() {
    local b=$(basename "$1")
    case "$b" in 
        *.*)
            echo "${b##*.}";;
    esac
}

