
# load config
mainconf="$OSUGM_CONF/osgum.conf"
source "$mainconf" || error "Missing main configuration file '$mainconf'"
[[ -n $OSUGM_NAME ]] || error "Missing OSUGM_NAME variable in '$mainconf'"
unset mainconf

# direct_start {name} {rundir} {cmd args...}
direct_start () {
    local name="$1"
    local rundir="$2"
    shift 2
    log info "starting $name"
    cd "$rundir"
    exec $@
    if [[ $? -ne 0 ]]; then
        error "$name returned $?"
    fi
}

# screen_exists {name}
screen_exists () {
    screen -list | grep "$OSUGM_NAME.$1" | grep -qv grep
}

# screen_start {name} {testfunc} {wait secs} {rundir} {cmd args...} 
screen_start () {
    local name="$1"
    local testfunc="$2"
    local wait=$3
    local rundir="$4"
    local elapsed=0
    shift 4

    log info -n "$name starting "
    ( cd "$rundir" && screen -d -m -S "$OSUGM_NAME.$name" $cmd )
    # wait until pid file is created
    while :
    do
        sleep 1
        elapsed=$((elapsed + 1))
        echo -n '.'
        if $testfunc; then
            echo ' running'
            return 0
        elif [[ $elapsed -ge $wait ]]; then
            echo -e '\n'
            error "$name failed to start within $wait seconds"
        fi
    done
}

# screen_stop {name} {testfunc} {wait secs} {pidfile}
screen_stop () {
    local name=$1
    local testfunc=$2
    local wait=$3
    local pidfile="$4"
    local elapsed=0
    shift 4

    echo -n "$name stopping"
    screen_send $name quit
    while :
    do
        sleep 2
        elapsed=$((elapsed + 2))
        echo -n '.'
        if $testunc; then
            echo ' stopped'
            return 0
        elif [[ $elapsed -ge 120 ]]; then
            echo ' too long... killing!'
            kill_pidfile $name "$pidfile"
            return 1
        fi
    done
}

# screen_attach {name}
screen_attach () {
    screen -r -S "$OSUGM_NAME.$1"
}

# screen_send {name} {command}
screen_send () {
    local name="$1"
    shift
    screen -r -S "$OSUGM_NAME.$name" -X stuff "$@ $(printf '\r')"
}
