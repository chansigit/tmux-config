#!/usr/bin/env bash
# Push the live ~/.tmux.conf back to this repo (for machines where ~/.tmux.conf is a copy, not a symlink).
#   ./sync.sh ["commit message"]
set -euo pipefail
cd "$(dirname "$0")"
if [ "$(readlink -f ~/.tmux.conf)" != "$(readlink -f tmux.conf)" ]; then cp ~/.tmux.conf tmux.conf; fi
if git diff --quiet -- tmux.conf shell; then echo "nothing to sync"; exit 0; fi
git add tmux.conf shell && git commit -q -m "${1:-sync tmux.conf from $(hostname -s) $(date +%F)}" && git push -q && echo "synced"
