#!/usr/bin/env bash
# Removes the launchd agent.
set -euo pipefail

LABEL="io.github.bunyodrafikov.agent-maxprime"
DEST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$UID/$LABEL" 2>/dev/null || true
rm -f "$DEST"
echo "removed $DEST"
