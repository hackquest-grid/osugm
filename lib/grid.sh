[ "$OSUGM_ROOT" ] || {
    echo "\$OSUGM variable is not set, do not call this script directly" >&2
    exit 1
}

grid_available () {
  ls "$OSUGM_CONF/available/"
}

grid_enabled () {
  ls "$OSUGM_CONF/enabled/"
}

grid_disabled () {
  all=$(grid_available)
  declare -a disabled
  for sim in $all; do
    if ! [ -h "$OSUGM_CONF/enabled/$sim" ]; then
      disabled[${#disabled[@]}]=$sim
    fi
  done
  echo ${disabled[@]}
}