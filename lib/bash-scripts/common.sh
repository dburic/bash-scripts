# common.sh - common functions for bash programs

PACKAGE="bash-scripts"
CONFIGDIR="${XDG_CONFIG_HOME:-$HOME/.config}/$PACKAGE"
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}/$PACKAGE"
STATEDIR="${XDG_STATE_HOME:-$HOME/.local/state}/$PACKAGE"
PROGNAME=$(basename -- "$0")
REALPATH=$(realpath -- "$0")
PRINTNAME=false # Should messages begin with the program's name?
OPTIONS=""
SHORTOPTS=""
LONGOPTS=""

# Print a message to stderr
printmsg() {
    $PRINTNAME && echo -n "$PROGNAME: " >&2
    echo "$1" >&2
}

# Print a warning
warn() {
    printmsg "warning: $1"
}

# Array of error messages
declare -g -A ERRORMSGS

# Add error messages
adderrormsgs() {
    while [ $# -ge 2 ]; do
        ERRORMSGS["$1"]="$2"
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
    INVARG     'invalid argument %s' \
    MISSARG    'missing required argument' \
    NODO       'nothing to do' \
    RC         'error in config file %s' \
    CHILD      '%s exited with non-zero status' \
    EXIST      '%s already exists' \
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
    MISSCMD    'missing command' \
    NOTCMD     '%s is not a command'

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

# Return error message given its code
errormsg() {
    local code="$1"
    if inlist "$code" "${!ERRORMSGS[@]}"; then
        echo "${ERRORMSGS["$code"]}"
    else 
        echo "unknown error code $code"
    fi
}

# Exit due to error
die() {
    local msg 
    if [[ "$1" =~ [A-Z][A-Z0-9_]* ]]; then # Look for predefined error msg
        local code="$1"
        shift
        printf -v msg "$(errormsg "$code")" "$@"
    else 
        msg="$1" 
    fi
    printmsg "error: $msg"
    exit 1
}

# This should probably be redefined
showhelp() {
    echo "Use the source, Luke! ;)"
}

# Prepare short and long options for getopt
setopts() {
    local line s="" l=""
    while read line; do
        [ -n "$line" ] || continue # Skip empty lines
        set -- $line # Separate line into words
        while [ -n "$1" ]; do
            case "$1" in
                # Long and short option with value
                */*:)   s+="${1%/*}:"; [ -n "$l" ] && l+=","; l+="${1#*/}";;
                # Long and short option without value
                */*)    s+="${1%/*}";  [ -n "$l" ] && l+=","; l+="${1#*/}";;
                # Only short option with or without value
                *)      s+="$1";;
            esac
            shift
        done
    done <<<"$OPTIONS"
    SHORTOPTS="$s"
    LONGOPTS="$l"
}

# Is variable $1 set?
isset() {
    declare -p "$1" >/dev/null 2>&1
}

# Is $1 an integer?
isint() {
    [ -n "$1" ] && printf "%d" "$1" >/dev/null 2>&1
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
    [ -n "$1" ] && printf "%e" "$1" >/dev/null 2>&1
}

# Nonnegative float?
isnnfloat() {
    isfloat "$1" && (printf "%e" "$1" | grep -q '^[0-9]')
}

# Positive float?
ispsfloat() {
    isfloat "$1" && (printf "%e" "$1" | grep -q '^[1-9]')
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

# Join $2, $3, ... using separator $1
joinargs() {
    local sep="$1" res="" val
    shift
    for val; do
        [ -z "$res" ] && res="$val" || res+="$sep$val"
    done
    echo "$res"
}


# Join $1, $2, ... with / and remove extra /'s; empty arguments are ignored
joinpaths() {
    local p r=""
    for p; do
        [ -z "$p" ] && continue
        [ -n "$r" ] && r+="/$p" || r="$p"
    done
    echo "$r" | sed -e 's!/\+!/!g'
}

# Return extension of $1 if it has one, otherwise return nothing
fileext() {
    local b=$(basename "$1")
    case "$b" in 
        *.*)
            echo "${b##*.}";;
    esac
}

# Create directory or die trying
mkdirordie() {
    mkdir -p "$1" || die MKDIR "$1"
}


