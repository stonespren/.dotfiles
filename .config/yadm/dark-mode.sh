#!/bin/bash

set -euo pipefail

applied=0

set_gsettings_if_needed() {
  local schema="$1"
  local key="$2"
  local target="$3"
  local current

  if ! gsettings writable "$schema" "$key" >/dev/null 2>&1; then
    return
  fi

  current="$(gsettings get "$schema" "$key" 2>/dev/null || true)"
  current="${current//\'}"
  if [ "$current" != "$target" ]; then
    gsettings set "$schema" "$key" "$target"
  fi
  applied=1
}

if command -v gsettings >/dev/null 2>&1; then
  set_gsettings_if_needed org.gnome.desktop.interface color-scheme "prefer-dark"
  set_gsettings_if_needed org.gnome.desktop.interface gtk-theme "Adwaita-dark"
fi

if [ "$applied" -eq 0 ] && command -v lookandfeeltool >/dev/null 2>&1; then
  if lookandfeeltool -a org.kde.breezedark.desktop >/dev/null 2>&1; then
    applied=1
  fi
fi

if [ "$applied" -eq 0 ] && command -v xfconf-query >/dev/null 2>&1; then
  current_theme="$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || true)"
  if [ "$current_theme" != "Adwaita-dark" ]; then
    xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita-dark >/dev/null 2>&1 || true
  fi
  if xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null | grep -Fxq "Adwaita-dark"; then
    applied=1
  fi
fi

if [ "$applied" -eq 1 ]; then
  echo "Dark mode enabled."
else
  echo "Could not enable dark mode automatically for this desktop session."
  exit 1
fi
