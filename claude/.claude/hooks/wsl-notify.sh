#!/bin/bash

# Claude Code WSL-to-Windows Toast Notification Hook
# Reads JSON from stdin, sends a Windows Toast notification via powershell.exe

# CONFIGURATION
ONLY_WHEN_UNFOCUSED=true  # Set to false to always show notifications

# 1. READ INPUT via stdin
input=$(cat)

# 2. PARSE JSON using jq
event_name=$(echo "$input" | jq -r '.hook_event_name // empty')
notif_type=$(echo "$input" | jq -r '.notification_type // empty')
message_raw=$(echo "$input" | jq -r '.message // empty')

# 3. DETERMINE NOTIFICATION CONTENT & URGENCY
title="Claude Code"
body=""
sound="Default"

if [ "$event_name" == "Notification" ]; then
    if [ "$notif_type" == "permission_prompt" ]; then
        title="⚠️ Permission Required"
        body="Claude needs your approval to proceed."
        sound="IM"
        if [ -n "$message_raw" ] && [ "$message_raw" != "null" ]; then
            body="$body ($message_raw)"
        fi
    elif [ "$notif_type" == "idle_prompt" ]; then
        title="💬 Input Waiting"
        body="Claude is waiting for your input."
        sound="IM"
    else
        title="Claude Code"
        body="${message_raw:-Notification from Claude Code}"
    fi
else
    title="Claude Code"
    body="Event: ${event_name:-unknown}"
fi

# 4. Fallback for empty body
if [ -z "$body" ]; then
    body="Claude Code notification"
fi

# 5. BASE64 ENCODE to avoid quoting issues across the WSL/Windows boundary
title_b64=$(echo -n "$title" | base64 -w 0)
body_b64=$(echo -n "$body" | base64 -w 0)

# 6. EXECUTE POWERSHELL to show Windows Toast notification
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
    # Check if terminal is the focused window (if enabled)
    if ('$ONLY_WHEN_UNFOCUSED' -eq 'true') {
        Add-Type @'
            using System;
            using System.Runtime.InteropServices;
            public class FocusCheck {
                [DllImport(\"user32.dll\")]
                public static extern IntPtr GetForegroundWindow();

                [DllImport(\"user32.dll\")]
                public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int processId);
            }
'@

        \$foregroundWindow = [FocusCheck]::GetForegroundWindow();
        \$processId = 0;
        [FocusCheck]::GetWindowThreadProcessId(\$foregroundWindow, [ref]\$processId) | Out-Null;

        \$focusedProcess = Get-Process -Id \$processId -ErrorAction SilentlyContinue;
        \$isFocused = \$focusedProcess -and (\$focusedProcess.ProcessName -eq 'WindowsTerminal' -or \$focusedProcess.ProcessName -eq 'wt');

        # Exit early if terminal is focused (don't show notification)
        if (\$isFocused) {
            exit 0;
        }
    }

    # Terminal is not focused, show the notification
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null;
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null;

    \$title = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$title_b64'));
    \$body  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$body_b64'));
    # Use PowerShell's AppId to avoid launching new terminal instances
    \$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe';

    # Create simple toast notification (passive alert - clicking dismisses)
    \$xml = \"<toast>
                <visual>
                    <binding template='ToastGeneric'>
                        <text>\$title</text>
                        <text>\$body</text>
                    </binding>
                </visual>
                <audio src='ms-winsoundevent:Notification.$sound'/>
            </toast>\";

    \$xmlDoc = [Windows.Data.Xml.Dom.XmlDocument]::new();
    \$xmlDoc.LoadXml(\$xml);
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\$appId).Show(\$xmlDoc);
" 2>/dev/null
