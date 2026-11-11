#!/bin/bash

set -euo pipefail

PASS_LOG_FILE="$HOME/.ssh/pp-agent.log"

# The installer drops the binary in ~/.local/bin, which may not be on PATH yet
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Install CLI
if ! command -v pass-cli >/dev/null 2>&1; then
  echo "Installing Proton Pass CLI..."
  curl -fsSL https://proton.me/download/pass-cli/install.sh | bash
  hash -r
fi

if ! command -v pass-cli >/dev/null 2>&1; then
  echo "pass-cli not found after install."
  exit 1
fi
echo "✓ Proton Pass CLI installed"

# Login
if ! pass-cli info >/dev/null 2>&1; then
  if [ ! -t 0 ]; then
    echo "Not logged in to Proton Pass and no interactive terminal; run 'pass-cli login' manually."
    exit 1
  fi
  echo "Logging in to Proton Pass..."
  pass-cli login
  if ! pass-cli info >/dev/null 2>&1; then
    echo "Proton Pass login failed."
    exit 1
  fi
fi
echo "✓ Logged in to Proton Pass"

# SSH public keys
fetch_public_key() {
  local item_id="$1"
  local share_id

  # Accept a full pass:// URI as well as a bare item ID
  if [[ "$item_id" == pass://* ]]; then
    pass-cli item view "${item_id%/public_key}/public_key" 2>/dev/null
    return
  fi

  # item view needs a vault, so try each one until the item is found
  while IFS= read -r share_id; do
    if pass-cli item view --share-id "$share_id" --item-id "$item_id" --field public_key 2>/dev/null; then
      return 0
    fi
  done < <(pass-cli vault list | sed -n 's/^- \[\(.*\)\]: .*/\1/p')
  return 1
}

ensure_public_key() {
  local name="$1"
  local pub_file="$HOME/.ssh/github-$name.pub"
  local item_id public_key

  if [ -s "$pub_file" ]; then
    # ssh refuses IdentityFile entries readable by others, even .pub ones
    chmod 600 "$pub_file"
    echo "✓ $pub_file already exists"
    return 0
  fi

  if [ ! -t 0 ]; then
    echo "No interactive terminal; skipping $pub_file."
    return 1
  fi

  # Discard leftover input (e.g. a trailing newline from a previous paste)
  while read -r -t 0.1 _; do :; done

  read -rp "Proton Pass item ID for the $name GitHub SSH key (blank to skip): " item_id
  item_id="${item_id//[[:space:]]/}"
  if [ -z "$item_id" ]; then
    echo "Skipping $pub_file."
    return 0
  fi

  if ! public_key="$(fetch_public_key "$item_id")" || [ -z "$public_key" ]; then
    echo "Could not read a public key from item '$item_id'."
    return 1
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  printf '%s\n' "$public_key" > "$pub_file"
  chmod 600 "$pub_file"
  echo "✓ Wrote $pub_file"
}

key_failures=0
ensure_public_key personal || key_failures=1
ensure_public_key rxco || key_failures=1

# SSH agent
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# True when an agent started with `daemon start` (outside systemd) is running.
# Capture first: piping into grep -q under pipefail can misreport a running agent
standalone_agent_running() {
  local status
  status="$(pass-cli ssh-agent daemon status 2>/dev/null || true)"
  grep -Eq '^Status:[[:space:]]+running' <<<"$status"
}

UNIT_NAME="proton-pass-ssh-agent.service"
UNIT_FILE="$HOME/.config/systemd/user/$UNIT_NAME"
UNIT_CONTENT="[Unit]
Description=Proton Pass SSH agent

[Service]
# Clear a socket left behind by a crash or unclean shutdown
ExecStartPre=-rm -f %h/.ssh/proton-pass-agent.sock
ExecStart=%h/.local/bin/pass-cli ssh-agent start --socket-path %h/.ssh/proton-pass-agent.sock
# Keep retrying, e.g. when the network is not up yet at login
Restart=always
RestartSec=10
StandardOutput=append:$PASS_LOG_FILE
StandardError=inherit

[Install]
WantedBy=default.target"

if systemctl --user show-environment >/dev/null 2>&1; then
  # Run the agent as a systemd user service so it starts at every login
  unit_changed=0
  if [ ! -f "$UNIT_FILE" ] || [ "$(cat "$UNIT_FILE")" != "$UNIT_CONTENT" ]; then
    mkdir -p "$(dirname "$UNIT_FILE")"
    printf '%s\n' "$UNIT_CONTENT" > "$UNIT_FILE"
    systemctl --user daemon-reload
    unit_changed=1
  fi

  # Hand the socket over from a standalone agent, if one is running
  if ! systemctl --user is-active --quiet "$UNIT_NAME" && standalone_agent_running; then
    pass-cli ssh-agent daemon stop
  fi

  if ! systemctl --user is-enabled --quiet "$UNIT_NAME"; then
    systemctl --user enable "$UNIT_NAME"
  fi

  if ! systemctl --user is-active --quiet "$UNIT_NAME"; then
    systemctl --user start "$UNIT_NAME"
    echo "✓ Proton Pass SSH agent service started"
  elif [ "$unit_changed" -eq 1 ]; then
    systemctl --user restart "$UNIT_NAME"
    echo "✓ Proton Pass SSH agent service restarted with updated config"
  else
    echo "✓ Proton Pass SSH agent service already running"
  fi
elif standalone_agent_running; then
  echo "✓ Proton Pass SSH agent already running (no systemd user session)"
else
  pass-cli ssh-agent daemon start --log-file "$PASS_LOG_FILE"
  echo "✓ Proton Pass SSH agent started (no systemd user session; will not start at login)"
fi

exit "$key_failures"
