[ "$OSUGM_ROOT" ] || {
    echo "\$OSUGM variable is not set, do not call this script directly" >&2
    exit 1
}

sim_cmd () {
  source_or_die "$OSUGM_LIB/run.sh"
  [ "$2" ] || $OSUGM help
  export OSUGM_SIMNAME="$2"
  export OSUGM_SIMCONF="$OSUGM_CONF/available/$OSUGM_SIMNAME"
  export OSUGM_SIMRUN="$OSUGM_RUN/opensim.$OSUGM_SIMNAME"


}