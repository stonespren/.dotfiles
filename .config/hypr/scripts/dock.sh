#!/usr/bin/env bash

INTERNAL="eDP-1"

has_external() {
    hyprctl monitors | grep -qv "$INTERNAL"
}

lid_closed() {
    grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null
}

apply_state() {
    if has_external && lid_closed; then
        hyprctl keyword monitorv2 "output=$INTERNAL, disable"
    else
        hyprctl keyword monitorv2 "output=$INTERNAL, mode=preferred, scale=2"
    fi
}

# Run once on startup
apply_state

# Listen for ACPI lid events
acpi_listen | while read -r line; do
    if echo "$line" | grep -qi lid; then
        sleep 1
        apply_state
    fi
done

