[ "$OSUGM_ROOT" ] || {
    echo "\$OSUGM variable is not set, do not call this script directly" >&2
    exit 1
}

msgrob='Robust'

robust_exists () {
  ps -ef -U $USER -u $USER | grep ' Robust.dll' | grep -qv grep
}

robust_status () {
  if robust_exists; then
    echo "$msgrob running"
    return 0
  fi
  echo "$msgrob offline"
  return 10
}

robust_cmd () {
  source_or_die "$OSUGM_LIB/run.sh"
  export OSUGM_GRIDDATA="$OSUGM_DATA/grid"

  case "$1" in
  status)
    robust_status
    ;;
  direct|start)
    mkdir -p "$OSUGM_GRIDDATA" || exit $?
    if robust_exists; then
      log warn "$msgrob is already running. Use '$OSUGM robust console' to view it"
      return 0
    fi

    # check user config
    [ -f "$OSUGM_CONF/Robust.ini" ] || error "Cannot find user configuration '$OSUGM_CONF/Robust.ini'"
    [ -f "$OSUGM_CONF/Database.ini" ] || error "Cannot find user configuration '$OSUGM_CONF/Database.ini'"
    [ -d "$OSUGM_EXEC/$OSUGM_OPENSIM" ] || error "Opensim directory '$OSUGM_OPENSIM' does not exist"

    # allow user overriding logging options
    logconfig="$OSUGM_LIB/conf/Robust.exe.config"
    if [ -f "$OSUG_CONF/Robust.exe.config" ]; then
      logconfig="$OSUGM_CONF/Robust.exe.config"
    fi

    cmd="env LANG=C $OSUGM_DOTNET Robust.dll \
        -inifile=\"$OSUGM_LIB/conf/Robust.ini\" \
        -logconfig=\"$logconfig\""
    if [[ $1 = 'direct' ]]; then
      direct_start $msgrob "$OSUGM_EXEC/$OSUGM_OPENSIM/bin" $cmd
    else
      screen_start $msgrob robust_exists 10 "$OSUGM_EXEC/$OSUGM_OPENSIM/bin" $cmd
    fi
    ;;
  stop)
    if ! robust_exists; then
      log warn "$msgrob is not started"
      exit 0
    fi
    if screen_exists $msgrob; then
      screen_stop $msgrob robust_exists 120 "$OSUGM_GRIDDATA/Robust.exe.pid"
    else
      log warn "$msgrob started manually, stop it from the console"
    fi
    ;;
  restart)
    robust_cmd stop && robust_cmd start
    ;;
  kill)
    kill_pidfile $msgrob "$"
    ;;
  console)
    screen_attach $msgrob
    ;;
  *)
    $OSUGM help
  esac
}