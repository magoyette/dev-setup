# Claude Code colors in tmux — investigation notes

## Problem

Claude Code renders with washed-out, low-saturation "whitish" colors inside
tmux. Colors are correct outside tmux. Emacs renders correctly inside tmux
with the same configuration.

## Root cause

Claude Code's Node.js terminal rendering library outputs **256-color** escape
sequences (`\e[38;5;Nm`) instead of **truecolor** sequences
(`\e[38;2;R;G;Bm`) when running inside tmux. The 256-color palette maps
truecolor values to the nearest available color, causing noticeable
desaturation.

### Evidence

Captured pane output shows 256-color codes:

```text
[38;5;246m  ⎿  No matches found[39m
```

If truecolor were active, these would use the `38;2;R;G;B` format instead.

### Why Emacs is unaffected

Emacs performs its own terminal capability detection, checking `$COLORTERM`
directly, and renders truecolor escape sequences regardless of what the
terminfo database says. Claude Code relies on the Node.js `supports-color` /
`chalk` library chain, which apparently falls back to 256 colors inside tmux
despite the correct environment variables.

## Environment (confirmed correct)

| Setting                    | Value            |
| -------------------------- | ---------------- |
| `TERM`                     | `tmux-256color`  |
| `COLORTERM`                | `truecolor`      |
| `FORCE_COLOR`              | `3`              |
| tmux `default-terminal`    | `tmux-256color`  |
| tmux `terminal-overrides`  | `*:RGB`          |
| tmux `terminal-features`   | `*:RGB`          |
| tmux `window-active-style` | `default`        |
| tmux `window-style`        | `default`        |
| Outer terminal             | `xterm-256color` |

## What was ruled out

- **`TERM` variable**: Changing to `xterm-256color` did not help.
- **`FORCE_COLOR` / `COLORTERM`**: Unsetting both did not help. Setting them
  explicitly did not help.
- **OneDark theme `window-active-style` override**: The theme sets
  `fg=#aab2bf` on active panes, but the post-TPM override resets it to
  `default` (confirmed via `tmux show-option`).
- **Pane-level or window-level style overrides**: None set.
- **tmux RGB capability**: `terminal-overrides` and `terminal-features` both
  include `*:RGB`. Raw truecolor escape sequences render correctly when
  printed via `printf`.

## Additional session context

There were actually **two separate tmux color problems** during this session:

1. **Pane-wide color distortion from `tmux-onedark-theme`**
   - The theme sets `window-style` and `window-active-style`.
   - This caused full-screen terminal apps such as Emacs and Claude Code to
     inherit pane styling from tmux.
   - Overriding both back to `default` fixed Emacs and removed the broad
     pane-tinting issue.

2. **Claude Code-specific palette mismatch that remained afterward**
   - After the tmux pane-style override, Emacs colors matched direct WSL
     again, but Claude Code still showed a slightly different palette
     (for example, the mascot looked more coral than orange).
   - That means the remaining issue is specific to Claude Code's rendering
     path, not a generic tmux theme problem.

### Repo-side mitigations already applied

- `tmux/.tmux.conf`
  - `default-terminal "tmux-256color"`
  - `terminal-overrides ",*:RGB"`
  - `terminal-features ",*:RGB"`
  - `update-environment " COLORTERM"`
  - `set-environment -g COLORTERM "truecolor"`
  - `window-style "default"`
  - `window-active-style "default"`
- Managed `claude()` wrapper
  - exports `COLORTERM=truecolor`
  - exports `FORCE_COLOR=3`

### Local Claude Code inspection

The installed Claude Code version in this session was `2.1.81`.

Local inspection of its bundled CLI code showed:

- no explicit `tmux-256color` special case in its embedded color support
  detection
- `COLORTERM=truecolor` should promote color support to 16m / truecolor
- `FORCE_COLOR=3` should also promote color support to 16m / truecolor

That weakens the simple "Claude only sees 256-color because tmux hides
truecolor" explanation. A more precise statement is:

- tmux truecolor signaling appears to be configured correctly
- Claude Code still emits at least some 256-color output inside tmux
- therefore the remaining mismatch is likely in a Claude Code rendering path
  or theme path that does not fully follow the expected 16m color-support
  branch

## Likely cause in Claude Code

Claude Code is built on [Ink](https://github.com/vadimdemedes/ink) (React for
CLIs), which uses [chalk](https://github.com/chalk/chalk) and
[supports-color](https://github.com/chalk/supports-color) for color
detection.

`supports-color` checks (in order):

1. `FORCE_COLOR` env var (should give level 3 = truecolor)
2. Various `TERM_PROGRAM` checks
3. `COLORTERM` env var (`truecolor` or `24bit` → level 3)
4. `TERM` variable patterns

With `FORCE_COLOR=3`, level 3 (truecolor) should be selected. The fact that
256-color codes appear suggests either:

- Claude Code overrides color detection internally
- A different rendering path is used that bypasses `supports-color`
- The version of `supports-color` bundled has different behavior

## Next steps to try

1. **Check Claude Code's bundled `supports-color` version** — locate it in
   the Claude Code installation and check if it respects `FORCE_COLOR=3`
   correctly.
2. **File an issue with Claude Code** — this may be a bug in how Claude Code
   detects terminal capabilities inside tmux.
3. **Test with `TERM_PROGRAM`** — try setting `TERM_PROGRAM=iTerm.app` or
   `TERM_PROGRAM=WezTerm` before launching Claude Code, as some color
   libraries use this for truecolor detection.
4. **Try `COLORTERM=truecolor` without `FORCE_COLOR`** — in case `FORCE_COLOR`
   is capping the level despite the value of `3`.
