[ "$OSUGM_ROOT" ] || {
    echo "\$OSUGM variable is not set, do not call this script directly" >&2
    exit 1
}

sim_init () {
  mkdir -p "$OSUGM_SIMCONF/regions" || error "Cannot create $OSUGM_SIMCONF/regions"
  log info "Creating files for '$msgsim' instance..."
  [[ -f $OSUGM_SIMCONF/instance.conf ]] || cp "$OSUGM_LIB/templates/instance.conf" "$OSUGM_SIMCONF" || exit 1
  [[ -f $OSUGM_SIMCONF/Local.ini ]] || cp "$OSUGM_LIB/templates/Local.ini" "$OSUGM_SIMCONF" || exit 1
  [[ -f $OSUGM_CONF/OpenSim.ini ]] || cp "$OSUGM_LIB/templates/OpenSim.ini" "$OSUGM_CONF" || exit 1
  log info "Done. Do not forget to edit your new configuration in\n\t$(bold $OSUGM_SIMCONF)"
}

sim_exists () {
  ps -ef -U $USER -u $USER | grep "$OSUGM_MONO OpenSim.exe" | grep "$OSUGM_SIMCONF" | grep -qv grep
}

sim_status () {
  if sim_exists; then
    echo "OpenSim $msgsim running"
    return 0
  fi
  echo "OpenSim $msgsim offline"
  return 10
}

sim_cmd () {
  source_or_die "$OSUGM_LIB/run.sh"
  if [[ -z $2 ]]; then
    "$OSUGM_BIN/$OSUGM" help
    exit 1
  fi
  export OSUGM_SIMNAME="$2"
  export OSUGM_SIMCONF="$OSUGM_CONF/available/$OSUGM_SIMNAME"
  export OSUGM_SIMRUN="$OSUGM_RUN/opensim.$OSUGM_SIMNAME"
  msgsim="$OSUGM_SIMNAME"
  set_logfile "$OSUGM.$OSUGM_SIMNAME.log"

  if [[ $1 = init ]]; then
    sim_init
    exit 0
  fi

  [[ -r $OSUGM_SIMCONF/instance.conf ]] || error "Missing file '$OSUGM_SIMCONF/instance.conf'"
  source_or_die "$OSUGM_SIMCONF/instance.conf"
  [[ -n $OSUGM_SIMPORT ]] || error "Missing variable OSUGM_SIMPORT in '$OSUGM_SIMCONF/instance.conf'"

  case "$1" in
  status)
    sim_status
    ;;
  enable)
    [[ -r $OSUGM_CONF/available/$OSUGM_SIMNAME ]] || error "'$OSUGM_SIMNAME' instance does not exists"
    [[ -h $OSUGM_CONF/enabled/$OSUGM_SIMNAME ]] && error "'$OSUGM_SIMNAME' is already enabled"
    cd "$OSUGM_CONF/enabled" && ln -s "$OSUGM_CONF/available/$OSUGM_SIMNAME" || exit $?
    log info "$(bold $OSUGM_SIMNAME) instance enabled for running with grid"
    ;;
  disable)
    [[ -h $OSUGM_CONF/enabled/$OSUGM_SIMNAME ]] || error "'$OSUGM_SIMNAME' is not an enabled instance"
    rm -f "$OSUGM_CONF/enabled/$OSUGM_SIMNAME" || exit $?
    log info "$(bold $OSUGM_SIMNAME) disabled from running with grid"
    ;;
  direct|start)
    if sim_exists; then
      log warn "$msgsim is already running. Use '$OSUGM sim console $OSUGM_SIMNAME' to view it"
      return 0
    fi

    # allow user overriding logging options
    logconfig="$OSUGM_LIB/conf/OpenSim.exe.config"
    if [[ -f $OSUGM_SIMCONF/OpenSim.exe.config ]]; then
      logconfig="$OSUGM_SIMCONF/OpenSim.exe.config"
    fi

    cmd="env LANG=C $OSUGM_MONO OpenSim.exe \
      -inifile=\"$OSUGM_LIB/conf/OpenSim.ini\" \
      -inidirectory=\"$OSUGM_SIMCONF\" \
      -logconfig=\"$logconfig\""
    if [[ $1 = 'direct' ]]; then
      direct_start $msgsim "$OSUGM_EXEC/$OSUGM_OPENSIM/bin" $cmd
    else
      screen_start $msgsim sim_exists 10 "$OSUGM_EXEC/$OSUGM_OPENSIM/bin" $cmd
    fi
    ;;
  stop)
    if ! sim_exists; then
      log warn "$msgsim is not running"
      return 0
    fi
    if screen_exists "$msgsim"; then
      screen_stop $msgsim sim_exists 60 "$OSUGM_SIMRUN/OpenSim.exe.pid"
    else
      log warn "$msgsim started manually, stop it from the console"
    fi
    ;;
  restart)
    $0 stop && $0 start
    ;;
  kill)
    kill_pidfile $msgsim "$OSUGM_SIMRUN/OpenSim.exe.pid"
    ;;
  console)
    screen_attach "$OSUGM_SIMNAME"
    ;;
  *)
   $OSUGM help
  esac
}