#!/usr/bin/env bash
# Time-agnostic runner. Drives one or more interactive AI CLIs from the repo
# dir, sending "Hey!" to each and quitting once the response settles.
#
# Usage: run-checkin.sh [agent ...]
#   agent   CLI binaries to drive in order (default: codex claude)
#
# Examples:
#   run-checkin.sh             # codex + claude
#   run-checkin.sh codex       # just codex
#   run-checkin.sh claude      # just claude

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRIVER="$REPO_DIR/lib/drive-agent.expect"

CACHE_DIR="${HOME}/Library/Caches/agent-maxprime"
mkdir -p "$CACHE_DIR"

# launchd strips PATH; re-add common bin dirs so codex/claude/expect resolve.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$CACHE_DIR/run-$STAMP.log"

# Keep only the 10 most recent run logs.
ls -1t "$CACHE_DIR"/run-*.log 2>/dev/null | tail -n +11 | xargs -I{} rm -f {} 2>/dev/null || true

AGENTS=("$@")
if [ ${#AGENTS[@]} -eq 0 ]; then
    AGENTS=(codex claude)
fi

cd "$REPO_DIR"

run_agent() {
    local name="$1"
    echo "=== $(date '+%Y-%m-%d %H:%M:%S') :: $name ==="
    if ! command -v "$name" >/dev/null 2>&1; then
        echo "[skip] '$name' not on PATH"
        return
    fi
    expect "$DRIVER" "$name" || echo "[warn] $name driver exited non-zero"
    echo
}

{
    echo "agent-maxprime run @ $(date)"
    echo "cwd: $(pwd)"
    echo "agents: ${AGENTS[*]}"
    echo
    for agent in "${AGENTS[@]}"; do
        run_agent "$agent"
    done
    echo "=== done @ $(date '+%Y-%m-%d %H:%M:%S') ==="
} >>"$LOG" 2>&1
