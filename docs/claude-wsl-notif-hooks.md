# Claude Code WSL-to-Windows Notifications

Native Windows Toast notifications for Claude Code running in WSL2. Get notified when Claude needs your permission or is waiting for input, even when you're in another window.

## Clicking on notifications

Clicking a notification dismisses it but does not focus the terminal window. Using Windows Terminal's AUMID as the toast AppId was tested but it opens a new tab in the existing instance rather than focusing the current one, so the hook uses PowerShell's AppId instead for passive dismiss-only toasts.

## Customization

### Focus-Aware Notifications (Default: Enabled)

By default, notifications only appear when your terminal is **not** the active window. This prevents notification spam while you're actively working with Claude Code.

To **always show notifications** regardless of window focus, edit `~/.claude/hooks/wsl-notify.sh`:

```bash
# Change this line at the top of the file:
ONLY_WHEN_UNFOCUSED=false  # Set to true to only notify when unfocused
```

### Other Customizations

You can modify `~/.claude/hooks/wsl-notify.sh` to:

- Change notification sounds (available: `Default`, `IM`, `Mail`, `Reminder`, `SMS`)
- Customize titles and messages
- Add additional hook events (see Claude Code hooks documentation)
- Modify the focus check to detect other terminal emulators (change `WindowsTerminal` or `wt` in the focus detection code)
