[ "$OSUGM_ROOT" ] || {
    echo "\$OSUGM variable is not set, do not call this script directly" >&2
    exit 1
}

grid_available () {
  ls "$OSUGM_CONF/available/"
}

grid_enabled () {
  ls "$OSUGM_CONF/enable/"
}

