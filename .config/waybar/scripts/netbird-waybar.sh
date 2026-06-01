#!/usr/bin/env bash

set -euo pipefail

management_url="https://vpn.rxco.co"

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

has_netbird() {
  command -v netbird >/dev/null 2>&1
}

get_status_output() {
  if ! has_netbird; then
    printf 'netbird CLI not found in PATH\n'
    return 127
  fi

  netbird status 2>&1
}

status_class() {
  local output=$1

  if grep -q '^Management: Connected$' <<<"$output"; then
    printf 'connected\n'
  elif grep -q '^Management:' <<<"$output"; then
    printf 'connecting\n'
  else
    printf 'disconnected\n'
  fi
}

peer_summary() {
  local output=$1
  local peers

  peers=$(sed -n 's/^Peers count: \(.*\)$/\1/p' <<<"$output")
  if [[ -n "$peers" ]]; then
    printf '%s\n' "$peers"
  fi
}

emit_json() {
  local text=$1
  local class=$2
  local tooltip=$3

  printf '{"text":%s,"class":%s,"tooltip":%s}\n' \
    "$(printf '%s' "$text" | json_escape)" \
    "$(printf '%s' "$class" | json_escape)" \
    "$(printf '%s' "$tooltip" | json_escape)"
}

status_module() {
  local output class text

  if ! output=$(get_status_output); then
    if has_netbird; then
      emit_json "󰌿 down" "disconnected" "$output"
    else
      emit_json "󰌿 unavailable" "error" "$output"
    fi
    return 0
  fi

  class=$(status_class "$output")

  case "$class" in
    connected)
      text="󰌾 up"
      ;;
    connecting)
      text="󰌾 wait"
      ;;
    *)
      text="󰌿 down"
      ;;
  esac

  emit_json "$text" "$class" "$output"
}

toggle_label_module() {
  local output class text tooltip

  if ! output=$(get_status_output); then
    if has_netbird; then
      emit_json "Connect" "disconnected" "$output"
    else
      emit_json "NB ?" "error" "$output"
    fi
    return 0
  fi

  class=$(status_class "$output")

  if [[ "$class" == "connected" ]]; then
    text="Disconnect"
    tooltip="Disconnect NetBird"
  else
    text="Connect"
    tooltip="Connect NetBird"
  fi

  emit_json "$text" "$class" "$tooltip"
}

toggle_action() {
  local output class

  if ! output=$(get_status_output); then
    if has_netbird; then
      exec netbird up --management-url "$management_url"
    fi

    printf '%s\n' "$output" >&2
    return 1
  fi

  class=$(status_class "$output")

  if [[ "$class" == "connected" ]]; then
    exec netbird down
  fi

  exec netbird up --management-url "$management_url"
}

case "${1:-status}" in
  status)
    status_module
    ;;
  toggle-label)
    toggle_label_module
    ;;
  toggle-action)
    toggle_action
    ;;
  *)
    printf 'usage: %s {status|toggle-label|toggle-action}\n' "$0" >&2
    exit 1
    ;;
esac
