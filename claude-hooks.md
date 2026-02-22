# Claude Code WSL-to-Windows Notifications

Native Windows Toast notifications for Claude Code running in WSL2. Get notified when Claude needs your permission or is waiting for input, even when you're in another window.

## Features

- 🔔 **Native Windows Toast notifications** from WSL2 Claude Code
- ⚠️ **Permission prompts** - Get alerted when Claude needs approval to run commands
- 💬 **Input waiting** - Know when Claude is ready for your next instruction
- 🧠 **Focus-aware** - Only notifies when you're in a different window (configurable)
- 🔇 **Smart filtering** - Only notifies for important events (no spam)
- 🎯 **Simple & reliable** - Passive notifications that won't interfere with your workflow

## Prerequisites

- WSL2 (Ubuntu or other Linux distribution)
- Windows Terminal (or another WSL-capable terminal)
- Claude Code installed
- `jq` installed: `sudo apt-get update && sudo apt-get install -y jq`

### Manual Install (Step-by-Step)

If you prefer to install manually:

#### 1. Copy the hook script

```bash
# Create the hooks directory
mkdir -p ~/.claude/hooks

# Copy the notification script
cp wsl-notify.sh ~/.claude/hooks/wsl-notify.sh

# Make it executable
chmod +x ~/.claude/hooks/wsl-notify.sh
```

#### 2. Configure Claude Code hooks

Add the following to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/wsl-notify.sh"
          }
        ]
      }
    ]
  }
}
```

**Note:** If you already have other settings in `settings.json`, just add the `"hooks"` key alongside your existing configuration.

#### 3. Restart Claude Code

Exit and restart your Claude Code session for the hooks to take effect.

## Testing

To verify the notifications work:

1. Start a Claude Code session
2. Ask Claude to run a bash command (e.g., `ls -la`) - if permission mode requires approval, you'll get a toast notification
3. Let Claude finish a response and wait - you should see an "Input Waiting" notification

## Troubleshooting

### Notifications don't appear

- Check Windows **Focus Assist** settings (should not be set to "Alarms Only")
- Verify `jq` is installed: `which jq`
- Verify `powershell.exe` is accessible: `which powershell.exe`
- Check hook script is executable: `ls -la ~/.claude/hooks/wsl-notify.sh`

### Permission denied errors

Make sure the script is executable:

```bash
chmod +x ~/.claude/hooks/wsl-notify.sh
```

### Clicking on notifications

Clicking on a notification will simply dismiss it. The notifications are passive alerts - you'll need to manually switch to Windows Terminal when you see one. This simple approach avoids issues with terminal focus and new instance creation.

## Customization

### Focus-Aware Notifications (Default: Enabled)

By default, notifications only appear when your terminal is **not** the active window. This prevents notification spam while you're actively working with Claude Code.

To **always show notifications** regardless of window focus, edit `~/.claude/hooks/wsl-notify.sh`:

```bash
# Change this line at the top of the file:
ONLY_WHEN_UNFOCUSED=false  # Set to true to only notify when unfocused
```

**How it works:**

- Checks if Windows Terminal is the currently focused application
- If focused: silently skips the notification
- If unfocused: shows the notification normally

### Other Customizations

You can modify `~/.claude/hooks/wsl-notify.sh` to:

- Change notification sounds (available: `Default`, `IM`, `Mail`, `Reminder`, `SMS`)
- Customize titles and messages
- Add additional hook events (see Claude Code hooks documentation)
- Modify the focus check to detect other terminal emulators (change `WindowsTerminal` or `wt` in the focus detection code)
