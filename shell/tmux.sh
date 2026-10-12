# Shell helpers that go with this tmux config. Source from ~/.bashrc or ~/.zshrc:
#   [ -f ~/.tmux-config/shell/tmux.sh ] && . ~/.tmux-config/shell/tmux.sh

# attach to a named session: tt work
alias tt='tmux a -t '

# set the title of the current pane; shown in the pane border by pane-border-format
title() { printf '\033]2;%s\033\\' "$*"; }
