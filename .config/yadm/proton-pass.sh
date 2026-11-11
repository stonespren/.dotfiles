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

# SSH agent daemon
if pass-cli ssh-agent daemon status 2>/dev/null | grep -Eq '^Status:[[:space:]]+running'; then
  echo "✓ Proton Pass SSH agent already running"
else
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  pass-cli ssh-agent daemon start --log-file "$PASS_LOG_FILE"
  echo "✓ Proton Pass SSH agent started"
fi

exit "$key_failures"
