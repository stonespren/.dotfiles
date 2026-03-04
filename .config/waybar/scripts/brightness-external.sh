#!/usr/bin/env bash

STEP=5
VCP=10
BRIGHTNESS_FILE="/tmp/brightness"
BUSES_FILE="/tmp/ddc_buses"

[ -f "$BRIGHTNESS_FILE" ] || echo 50 > "$BRIGHTNESS_FILE"

get_buses() {
  [ -f "$BUSES_FILE" ] && cat "$BUSES_FILE"
}

case "$1" in
  up|down)
    CURRENT=$(<"$BRIGHTNESS_FILE")

    if [ "$1" = "up" ]; then
      NEW=$((CURRENT + STEP))
      (( NEW > 100 )) && NEW=100
    else
      NEW=$((CURRENT - STEP))
      (( NEW < 0 )) && NEW=0
    fi

    echo "$NEW" > "$BRIGHTNESS_FILE"

    for display in $(cat /tmp/ddc_displays 2>/dev/null); do
      ddcutil --display="$display" setvcp $VCP "$NEW" \
        --noverify --sleep-multiplier=0 >/dev/null 2>&1 &
    done

    echo "$NEW"
    ;;
  get)
    echo "$(<"$BRIGHTNESS_FILE")"
    ;;
esac
