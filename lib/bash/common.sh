# common.sh - common functions for shell programs

# Program's basename and realpath
PROGNAME=$(basename "$0")
REALPATH=$(realpath "$0")

# Should messages begin with the program's name? 0 = false, everything else = true
PRINTNAME=0

printmsg() {
    [ "$PRINTNAME" -ne 0 ] && echo -n "$PROGNAME: " >&2
    echo "$1" >&2
}

warn() {
    printmsg "warning: $1"
}

# Built-in error messages
_errormsg() {
    local msg
    local errorcode="$1"
    shift
    case "$errorcode" in
        SIGTERM)    msg="program terminated";;
        SIGINT)     msg="program interrupted by user";;
        INVOPT)     msg="invalid option, try --help";;
        MISSOPT)    msg="missing option $1";;
        UNPROCOPT)  msg="oops, unprocessed option $1";;
        INVVAL)     msg="invalid value $1";;
        MISSVAL)    msg="option $1 requires a value";;
        MISSARG)    msg="missing required argument";;
        INVARG)     msg="invalid argument $1";;
        NODO)       msg="nothing to do";;
        RC)         msg="error in config file $1";;
        CHILD)      msg="$1 exited with non-zero status";;
        EXISTS)     msg="$1 already exists";;
        NOTEXIST)   msg="$1 does not exist";;
        NOTFILE)    msg="$1 does not exist or is not a regular file";;
        NOTDIR)     msg="$1 is not a directory";;
        TEMPFILE)   msg="cannot create temporary file";;
        MKFILE)     msg="cannot create file $1";;
        MKDIR)      msg="cannot create directory $1";;
        RMFILE)     msg="cannot remove file $1";;
        RMDIR)      msg="cannot remove directory $1";;
        MOUNTED)    msg="$1 is already mounted";;
        NOTMOUNTED) msg="$1 is not mounted";;
        OTHER)      msg="$1";;
        *)          msg="unknown error $errorcode";;
    esac
    echo "$msg"
}

# If additional error messages are needed, then this should be redefined
# similar to _errormsg
errormsg() {
    echo ""
}

# Exit due to error
errorexit() {
    local msg
    msg=$(errormsg "$@")
    [ -z "$msg" ] && msg=$(_errormsg "$@")
    printmsg "error: $msg"
    exit 1
}

# This should probably be redefined
showhelp() {
    cat <<EOF
Use the source, Luke! ;)
EOF
}

# Make list of arguments from stdin or from command line arguments;
# arguments are separated by newlines; empty lines are filtered out
mkarglist() {
    local usestdin=$1
    shift
    if [ $usestdin -eq 0 ]; then
        local IFS=$'\n'
        echo "$*"
    else
        cat
    fi | grep .
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
    for v in "$@"; do 
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
    local r=""
    for p in "$@"; do
        [ -z "$p" ] && continue
        [ -n "$r" ] && r+="/$p" || r="$p"
    done
    echo "$r" | perl -p -e 's{/+}{/}g'
}

# Get the extension of a filename; note that "${1##*.}" alone would not
# work when the extension is misssing
getext() {
    case "$1" in
        *.*)
            echo "${1##*.}";;
    esac
}

