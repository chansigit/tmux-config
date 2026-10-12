# tmux-config

My tmux setup, kept in one place so any machine can be brought to the same look and behaviour with one command.

```bash
curl -fsSL https://raw.githubusercontent.com/chansigit/tmux-config/main/deploy.sh | bash
```

That clones this repo to `~/.tmux-config`, symlinks `~/.tmux.conf` to it (backing up whatever was there), installs
[TPM](https://github.com/tmux-plugins/tpm) and the plugins, checks the `tmux-256color` terminfo, and reloads a running
server. Re-running it updates everything. Needs `git` and tmux ≥ 3.3.

## What the config does

**Terminal and responsiveness**

| setting | effect |
|---|---|
| `history-limit 100000` | 100k lines of scrollback per pane |
| `default-terminal tmux-256color` | 256 colours plus italics; needs that terminfo entry (see below) |
| `escape-time 0` | no lag after pressing Esc, matters in vim |
| `allow-passthrough on` | lets programs inside tmux send escape sequences straight to the outer terminal (images, OSC 52 clipboard) |
| `update-environment TERM, TERM_PROGRAM` | a re-attached session picks up the new client's terminal type |
| `mouse on` | click to select panes and windows, drag to resize, wheel to scroll |
| `renumber-windows on` | closing window 2 of 5 leaves 1–4, no gaps |

**Keys**: `prefix |` splits side by side, `prefix -` splits top and bottom. Everything else is tmux default (prefix is `C-b`).

**Status bar, on top.** Dark green background (`colour22`) with cyan text (`colour44`):

```
 ◆ session ◆ host ◇   1:zsh   ▶ 2:vim ◀   3:logs        [prefix]  ◇ CPU: 12.3% ◇ ~/some/path ◆
```

Left shows session and host. The current window is highlighted in reverse (cyan on green, bold) with `▶ ◀` markers.
Right shows a flash when the prefix key is held (`tmux-prefix-highlight`, red background), CPU load (`tmux-cpu`),
and the last 30 characters of the current pane's directory.

**Panes.** Double-line borders in bright cyan (`#5ffdff`) on dark grey, with the pane title drawn in the top border.
Set a title from the shell with the `title` helper in `shell/tmux.sh`:

```bash
title build server     # the pane border now reads " build server "
```

**Quiet.** Activity monitoring and visual bells are off.

**Persistence.** `tmux-resurrect` saves and restores sessions (`prefix C-s` / `prefix C-r`), and `tmux-continuum`
does the save automatically every 15 minutes.

## Plugins

Managed by TPM in `~/.tmux/plugins`. Inside tmux: `prefix I` installs, `prefix U` updates.

- `tmux-plugins/tpm`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`
- `tmux-plugins/tmux-prefix-highlight`
- `tmux-plugins/tmux-cpu`

## Files

| file | purpose |
|---|---|
| `tmux.conf` | the config; `~/.tmux.conf` points here after deploy |
| `deploy.sh` | one-shot install / update |
| `sync.sh` | on a machine where `~/.tmux.conf` is a copy rather than a symlink, push its changes back to the repo |
| `shell/tmux.sh` | `tt` alias (`tt name` = attach to session) and the `title` function; source it from your rc file |
| `terminfo/tmux-256color.ti` | terminfo source for old hosts that lack the entry: `tic -x terminfo/tmux-256color.ti` |

## Old hosts

On CentOS 7 the system ncurses has no `tmux-256color`, and the stock tmux is 1.8. This config was built against a
locally compiled tmux 3.3a with ncurses 6.4; `deploy.sh` warns about both and the terminfo file above fixes the
first. If tmux cannot be upgraded, change `default-terminal` to `screen-256color` and drop `allow-passthrough`.
