#!/usr/bin/env bash

STEP=5
VCP=10
INDEX="${2:-1}"
BRIGHTNESS_FILE="/tmp/brightness-$INDEX"

[ -f "$BRIGHTNESS_FILE" ] || echo 50 > "$BRIGHTNESS_FILE"

case "$1" in
  up|down)
    DISPLAY=$(sed -n "${INDEX}p" /tmp/ddc_displays 2>/dev/null)
    [ -z "$DISPLAY" ] && exit 0
    CURRENT=$(<"$BRIGHTNESS_FILE")

    if [ "$1" = "up" ]; then
      NEW=$((CURRENT + STEP))
      (( NEW > 100 )) && NEW=100
    else
      NEW=$((CURRENT - STEP))
      (( NEW < 0 )) && NEW=0
    fi

    echo "$NEW" > "$BRIGHTNESS_FILE"
    ddcutil --display="$DISPLAY" setvcp $VCP "$NEW" \
      --noverify --sleep-multiplier=0 >/dev/null 2>&1 &

    echo "$NEW"
    ;;
  get)
    ddcutil detect --brief 2>/dev/null | awk '/^Display/ {print $2}' > /tmp/ddc_displays
    DISPLAY=$(sed -n "${INDEX}p" /tmp/ddc_displays 2>/dev/null)
    [ -z "$DISPLAY" ] && exit 0
    echo "$(<"$BRIGHTNESS_FILE")"
    ;;
esac
