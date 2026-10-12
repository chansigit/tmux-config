#!/usr/bin/env bash
# Deploy this tmux config on a fresh machine. Idempotent; re-run to update.
#   curl -fsSL https://raw.githubusercontent.com/chansigit/tmux-config/main/deploy.sh | bash
# Environment knobs: TMUX_CONFIG_DIR (default ~/.tmux-config), TMUX_CONFIG_REPO.
set -euo pipefail

REPO="${TMUX_CONFIG_REPO:-https://github.com/chansigit/tmux-config.git}"
DIR="${TMUX_CONFIG_DIR:-$HOME/.tmux-config}"
TPM="$HOME/.tmux/plugins/tpm"

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
if ! command -v tmux >/dev/null; then
  warn "tmux not found; install tmux >= 3.3 (the config uses allow-passthrough) and re-run."
else
  v=$(tmux -V | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
  [ "$(printf '%s\n3.3\n' "$v" | sort -V | head -1)" = "3.3" ] || warn "tmux $v is older than 3.3; allow-passthrough will be ignored."
fi

# 1. config repo
if [ -d "$DIR/.git" ]; then
  say "updating $DIR"; git -C "$DIR" pull -q --ff-only
else
  say "cloning into $DIR"; git clone -q "$REPO" "$DIR"
fi

# 2. ~/.tmux.conf -> symlink into the repo (back up anything that is not already our link)
if [ -e "$HOME/.tmux.conf" ] && [ "$(readlink -f "$HOME/.tmux.conf")" != "$(readlink -f "$DIR/tmux.conf")" ]; then
  bak="$HOME/.tmux.conf.bak.$(date +%Y%m%d%H%M%S)"; say "backing up existing ~/.tmux.conf to $bak"; mv "$HOME/.tmux.conf" "$bak"
fi
ln -sfn "$DIR/tmux.conf" "$HOME/.tmux.conf"; say "~/.tmux.conf -> $DIR/tmux.conf"

# 3. TPM + plugins
if [ ! -d "$TPM" ]; then say "installing tpm"; git clone -q https://github.com/tmux-plugins/tpm "$TPM"; fi
say "installing plugins"; "$TPM/bin/install_plugins" >/dev/null && "$TPM/bin/update_plugins" all >/dev/null || warn "plugin install reported a problem; run prefix + I inside tmux"

# 4. terminfo for default-terminal tmux-256color
if command -v infocmp >/dev/null && ! infocmp tmux-256color >/dev/null 2>&1; then
  warn "terminfo 'tmux-256color' missing. On an old host, install ncurses >= 6.1 or run: tic -x $DIR/terminfo/tmux-256color.ti"
fi

# 5. live reload if a server is running
if command -v tmux >/dev/null && tmux list-sessions >/dev/null 2>&1; then
  tmux source-file "$HOME/.tmux.conf" && say "reloaded running tmux server"
fi

say "done. Shell helpers (tt alias, title function): add to your rc file:"
echo "    [ -f $DIR/shell/tmux.sh ] && . $DIR/shell/tmux.sh"
