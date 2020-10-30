
[ "$OSUGM_ROOT" ] || {
    echo "\$OSUGM variable is not set, do not call this script directly" >&2
    exit 1
}

OSUGM_PID=$$
[ "$OSUGM" ] || export OSUGM=$(basename $0)
[ "$OSUGM_CONF" ] || export OSUGM_CONF="$OSUGM_ROOT/conf"
[ "$OSUGM_BIN" ] || export OSUGM_BIN="$OSUGM_ROOT/bin"
#[ "$OSUGM_LIB" ] || export OSUGM_LIB="$OSUGM_ROOT/lib"
[ "$OSUGM_RUN" ] || export OSUGM_RUN="$OSUGM_ROOT/run"
[ "$OSUGM_EXEC" ] || export OSUGM_EXEC="$OSUGM_ROOT/opensim"

# red=31, green=32, yellow=33, blue=34, magenta=35, cyan=36, white=37
declare -A COLORS
COLORS['normal']='\e[0m'
COLORS['error']='\e[1;31m'
COLORS['warn']='\e[1;33m'
COLORS['info']='\e[1;34m'
COLORS['debug']='\e[1;35m'

OSUGM_LOG="$OSUGM_RUN/$OSUGM.$OSUGM_PID.log"

set_logfile () {
    OSUGM_LOG="$OSUGM_RUN/$1"
}

istrue () {
    local val=$(echo $1 | tr '[:upper:]' '[:lower:]')
    case $val in
    y|yes|1|t|true) return
    esac
    return -1
}

log () {
    local typ err msg line col noret

    case $1 in
#    [0-9][0-9]*)
#        typ='error'
#        col=$COLOR_ERROR
#        err="<$1>"
#        shift
#        ;;
    error|warn|info|debug)
        typ=$1
        col=${COLORS[$1]}
        shift
        ;;
    *)
        typ='info'
        col=$COLORS['info']
    esac
    [[ $1 = '-n' ]] && {
        noret=$1
        shift
    }
    msg=$@
    istrue $OSUGM_LOGGING && {
        mkdir -p "$OSUGM_RUN" || exit 1
        echo "$(date +"%Y-%m-%d %H:%M:%S") $typ$err $msg" >> "$OSUGM_LOG"
    }
    echo -e $noret "${col}$typ${COLORS['normal']} $msg" >&2
}

error () {
    log error "$@"
    exit 1
}

# kill_pidfile {name} {pidfile}
kill_pidfile () {
    if [[ -f "$2" ]]; then
        kill -9 $(cat "$2")
        rm "$2"
        log info "$1 killed"
    fi
}