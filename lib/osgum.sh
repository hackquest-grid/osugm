
# error <message>
error () {
    echo $* >&2; exit 1
}

# tmux_new <name> <startdir> <cmd> {<cmdarg> <cmdarg> ...}
tmux_new () {
    local name="$1"
    local dir="$2"
    shift 2

    if ! tmux -L "$OSUGM_NAME" list-sessions &>/dev/null; then
        tmux -L "$OSUGM_NAME" start-server
    fi
    tmux -L "$OSUGM_NAME" new-session -d -c "$dir" -s "$name" "$@"
}

# tmux_exists <name>
tmux_exists () {
    tmux -L "$OSUGM_NAME" list-sessions | grep -q "^$1:"
}

# tmux_show <name>
tmux_show () {
    tmux -L "$OSUGM_NAME" attach -t "$1"
}

# tmux_send <name> <input>
tmux_send () {
    local name="$1"
    shift
    tmux -L "$OSUGM_NAME" send-keys -t "=$name:0" "$@" "c-m"
}


# global variables
export OSUGM_CONF="$OSUGM_ROOT/conf"
mainconf="$OSUGM_CONF/osgum.conf"
source "$mainconf" || error "Missing main configuration file '$mainconf'"
[[ -n $OSUGM_NAME ]] || error "Missing OSUGM_NAME variable in '$mainconf'"
unset mainconf

export OSUGM_RUN="$OSUGM_ROOT/run"
export TMUX_TMPDIR="$OSUGM_RUN"
