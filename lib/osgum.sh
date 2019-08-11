
# # tmux_new <name> <startdir> <cmd> {<cmdarg> <cmdarg> ...}
# tmux_new () {
#     local name="$1"
#     local dir="$2"
#     shift 2

#     if ! tmux -L "$OSUGM_NAME" list-sessions &>/dev/null; then
#         tmux -L "$OSUGM_NAME" start-server
#     fi
#     tmux -L "$OSUGM_NAME" new-session -d -c "$dir" -s "$name" "$@"
# }

# # tmux_exists <name>
# tmux_exists () {
#     tmux -L "$OSUGM_NAME" list-sessions | grep -q "^$1:"
# }

# # tmux_show <name>
# tmux_show () {
#     tmux -L "$OSUGM_NAME" attach -t "$1"
# }

# # tmux_send <name> <input>
# tmux_send () {
#     local name="$1"
#     shift
#     tmux -L "$OSUGM_NAME" send-keys -t "=$name:0" "$@" "c-m"
# }

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
    return 1
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
    ( cd "$rundir" && screen -S "$name" $cmd )
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

# screen_stop {name} {testfunc} {wait secs}
screen_stop () {
    local name=$1
    local testfunc=$2
    local wait=$3
    local elapsed=0
    shift 3

    echo -n "$name stopping"
    screen_send $name quit
    while :
    do
        sleep 2
        elapsed=$((elapsed + 2))
        echo -n '.'
        if ! $testunc; then
            echo ' stopped'
            return 0
        elif [[ $elapsed -ge 120 ]]; then
            echo ' too long... killing!'
            kill_pidfile $name "$OSUGM_GRIDRUN/Robust.exe.pid"
            return 1
        fi
    done
}

# screen_attach {name}
screen_attach () {
    screen -r "$1"
}

# screen_send {name} {command}
screen_send () {
    local name="$1"
    shift
    screen -r "$name" -X stuff "$@ $(printf '\r')"
}
