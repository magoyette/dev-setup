# WSL Terminal Tab Title Issues

Setting the Windows Terminal tab title from WSL2 using standard OSC escape
sequences does not work due to a known ConPTY limitation.

## The problem

Standard escape sequences for setting the terminal title (`\033]0;title\007`,
`\e]2;title\e\\`) are silently consumed by ConPTY and never reach Windows
Terminal. This affects all shells running inside WSL2 (bash, zsh, etc.),
including bare sessions with no configuration (`bash --norc --noprofile`).

The same escape sequences work correctly from native PowerShell and Command
Prompt tabs, confirming the issue is specific to the WSL2-to-Windows Terminal
path through ConPTY.

## Root cause

WSL2 output flows through ConPTY (Windows Pseudo Console), which acts as a
bridge between WSL and Windows Terminal:

1. VT escape sequences from WSL are received by **conhost** (inside ConPTY)
2. Conhost **parses** OSC sequences internally (e.g., OSC 0 maps to
   `SetConsoleTitle`)
3. Conhost's VT renderer **re-serializes** only buffer changes back to Windows
   Terminal

OSC title sequences are consumed at step 2 and lost in the re-serialization at
step 3.

## Status

A major ConPTY passthrough refactoring was merged in August 2024
([microsoft/terminal PR #17510](https://github.com/microsoft/terminal/pull/17510)),
which aims to fix the ordering and loss of pass-through sequences. The fix
requires an updated **conhost.exe** shipped with Windows itself, not just an
updated Windows Terminal.

Relevant GitHub issues:

- [ConPTY Passthrough mode (#1173)](https://github.com/microsoft/terminal/issues/1173)
  -- the long-standing request, closed by PR #17510
- [Conpty pass-through ordering (#8698)](https://github.com/microsoft/terminal/issues/8698)
  -- OSC sequences dispatched out of order, closed by PR #17510
- [Rename tab title not working for WSL (#5333)](https://github.com/microsoft/terminal/issues/5333)
- [WSL tab ignores tabTitle (#3891)](https://github.com/microsoft/terminal/issues/3891)
- [WSL needs pure launcher, decoupling from ConPTY (WSL #9117)](https://github.com/microsoft/WSL/issues/9117)
  -- still open

## Tested (2026-03-22)

Environment: Windows Terminal 1.23.20211.0, WSL 2.6.3.0, Ubuntu.

All of the following failed to change the tab title from WSL:

```bash
printf '\033]0;test title\007'
echo -ne "\e]0;test title\a"
echo -ne "\033]2;test title\007"
printf '\e]0;test title\e\\'
printf '\e]0;test title\007' > /dev/tty
powershell.exe -Command '[Console]::Title = "test title"'
```

Setting the title from a native PowerShell tab works:

```powershell
$Host.UI.RawUI.WindowTitle = "test title"
```

## Workarounds

### Static titles per profile

Create separate Windows Terminal profiles with distinct `tabTitle` and
`suppressApplicationTitle` values:

```json
{
    "name": "WSL Dev",
    "source": "Microsoft.WSL",
    "tabTitle": "Dev",
    "suppressApplicationTitle": true,
    "tabColor": "#0078D4"
}
```

### Tab colors

Use `tabColor` per profile for quick visual grouping without relying on title
changes.

### Wait for Windows update

The ConPTY fix (PR #17510) should eventually ship in a Windows update. After
updating, remove `suppressApplicationTitle` and use PROMPT_COMMAND to set
dynamic titles:

```bash
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}printf '\033]0;%s\007' \"${PWD##*/}\""
```
