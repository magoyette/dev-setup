# Windows Terminal Setup

Windows Terminal settings aren't applied by the Ansible playbook, they must be
set manually in the application.

## Font and theme

- Font: `DejaVuSansM Nerd Font Mono` at `13 pt`. A Nerd font is required by
  ccstatusline, Starship and Emacs.
- Theme: `One Half Dark`.

## Keybinding conflicts to fix

Remove `ctrl+c` and `ctrl+v` keybindings that are used for copy and paste to avoid
conflicts with Emacs.

## Keybinding to add

Add an Action for `Rename tab` associated to `Ctrl+Alt+Shift+R`.

## Keybindings: `sendInput` CSI-u actions

Windows Terminal 1.24 (stable, the version this was written against) has no
extended-key protocol of its own, so several chords that terminal apps expect
(Shift+Enter, Ctrl+=, etc.) collapse to their unmodified form or don't arrive
at all. The fix is a `sendInput` action per chord that emits the byte sequence
the app already knows how to decode, bypassing Windows Terminal's own encoding.

The encoding used here is **CSI-u** (`ESC [ <keycode> ; <modifier> u`),
modifier `2`=Shift, `3`=Alt, `5`=Ctrl, `6`=Ctrl+Shift.

> **Retirement note.** These per-chord entries exist only because Windows
> Terminal 1.24 has no built-in extended-key protocol. Native
> Kitty-keyboard-protocol support landed in Windows Terminal Preview 1.25.
> Once a machine is on 1.25 or later (stable), re-test each chord in Emacs with
> `C-h k` — most of these entries should become redundant and can be deleted.
> The `ctrl+v` / `ctrl+c` adjustments below are unrelated to the protocol and
> stay regardless of Windows Terminal version.

Each entry needs **two** JSON pieces — an `actions` entry defining the
`sendInput` command, and a `keybindings` entry binding a physical chord to it.
Both are required; an `actions` entry with no matching `keybindings` entry does
nothing.

| Chord (`keys`)       | Sequence (`input`) | What it restores                      |
| -------------------- | ------------------ | ------------------------------------- |
| `shift+enter`        | `\u001b[13;2u`     | Pi: multiline input                   |
| `alt+enter`          | `\u001b[13;3u`     | Pi: follow-up queueing                |
| `ctrl+=`             | `\u001b[61;5u`     | Emacs: `er/expand-region`             |
| `ctrl+,`             | `\u001b[44;5u`     | Emacs: `avy-goto-char`                |
| `ctrl+'`             | `\u001b[39;5u`     | Emacs: `avy-goto-char-2`              |
| `ctrl+.`             | `\u001b[46;5u`     | Emacs: `mc-hide-unmatched-lines-mode` |
| `ctrl+shift+,` (`<`) | `\u001b[60;6u`     | Emacs: `mc/mark-previous-like-this`   |
| `ctrl+shift+.` (`>`) | `\u001b[62;6u`     | Emacs: `mc/mark-next-like-this`       |
| `ctrl+shift+enter`   | `\u001b[13;6u`     | Emacs: `crux-smart-open-line-above`   |

Add to `actions`:

```json
{ "command": { "action": "sendInput", "input": "\u001b[13;2u" }, "id": "User.sendInput.8882FD6D" },
{ "command": { "action": "sendInput", "input": "\u001b[13;3u" }, "id": "User.sendInput.237E8A98" },
{ "command": { "action": "sendInput", "input": "\u001b[61;5u" }, "id": "User.sendInput.CtrlEqual" },
{ "command": { "action": "sendInput", "input": "\u001b[44;5u" }, "id": "User.sendInput.CtrlComma" },
{ "command": { "action": "sendInput", "input": "\u001b[39;5u" }, "id": "User.sendInput.CtrlQuote" },
{ "command": { "action": "sendInput", "input": "\u001b[46;5u" }, "id": "User.sendInput.CtrlPeriod" },
{ "command": { "action": "sendInput", "input": "\u001b[60;6u" }, "id": "User.sendInput.CtrlShiftLess" },
{ "command": { "action": "sendInput", "input": "\u001b[62;6u" }, "id": "User.sendInput.CtrlShiftGreater" },
{ "command": { "action": "sendInput", "input": "\u001b[13;6u" }, "id": "User.sendInput.CtrlShiftEnter" }
```

Add to `keybindings`:

```json
{ "id": "User.sendInput.8882FD6D", "keys": "shift+enter" },
{ "id": "User.sendInput.237E8A98", "keys": "alt+enter" },
{ "id": "User.sendInput.CtrlEqual", "keys": "ctrl+=" },
{ "id": "User.sendInput.CtrlComma", "keys": "ctrl+," },
{ "id": "User.sendInput.CtrlQuote", "keys": "ctrl+'" },
{ "id": "User.sendInput.CtrlPeriod", "keys": "ctrl+." },
{ "id": "User.sendInput.CtrlShiftLess", "keys": "ctrl+shift+," },
{ "id": "User.sendInput.CtrlShiftGreater", "keys": "ctrl+shift+." },
{ "id": "User.sendInput.CtrlShiftEnter", "keys": "ctrl+shift+enter" }
```

### Running Emacs in a herdr pane

herdr (tested against v0.8.2) forwards a modified chord to the app running
inside a pane in full only if that app has enabled the Kitty keyboard protocol
for its pane. Without that opt-in, herdr downgrades and keybindings like `Ctrl+=` fails.

Emacs's `xterm.el` decodes CSI-u/Kitty-encoded input unconditionally, but it
never _enables_ the Kitty protocol itself. Forcing that on via
`xterm-extra-capabilities` was tried first and confirmed **not** sufficient:
it's a different protocol than the one herdr's tracker checks for. What
fixes it is the `kkp.el` package (MELPA), which sends the actual Kitty
enable sequence (`\e[>Nu`) after probing that the terminal supports it.
