#!/usr/bin/env bash
# Installs the launchd agent so the runner fires at 06:30, 11:30, and 16:30.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="io.github.bunyodrafikov.agent-maxprime"
SRC="$REPO_DIR/launchd/$LABEL.plist"
DEST_DIR="$HOME/Library/LaunchAgents"
DEST="$DEST_DIR/$LABEL.plist"

mkdir -p "$DEST_DIR"
mkdir -p "$HOME/Library/Caches/agent-maxprime"

# Substitute repo path and home into the template.
sed -e "s|__REPO__|$REPO_DIR|g" -e "s|__HOME__|$HOME|g" "$SRC" > "$DEST"

# Reload if already loaded.
launchctl bootout "gui/$UID/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID" "$DEST"

echo "installed -> $DEST"
echo "schedules:"
launchctl print "gui/$UID/$LABEL" 2>/dev/null | grep -A1 -E "calendar|next fire" || true
echo
echo "manual test: launchctl kickstart -k gui/$UID/$LABEL"
echo "logs:        ls -lt ~/Library/Caches/agent-maxprime/"
