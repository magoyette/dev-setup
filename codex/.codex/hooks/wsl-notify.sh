#!/bin/bash

# Codex WSL-to-Windows Toast Notification Hook
# Reads Codex hook JSON from stdin and sends a Windows Toast notification.

ONLY_WHEN_UNFOCUSED=true

input=$(cat)
event_name=$(echo "$input" | jq -r '.hook_event_name // empty')
message_raw=$(echo "$input" | jq -r '.tool_input.description // .tool_input.command // .last_assistant_message // empty')

title="Codex"
body=""
sound="Default"

if [ "$event_name" = "PermissionRequest" ]; then
    title="Permission Required"
    body="Codex needs your approval to proceed."
    sound="IM"
    if [ -n "$message_raw" ] && [ "$message_raw" != "null" ]; then
        body="$body ($message_raw)"
    fi
elif [ "$event_name" = "Stop" ]; then
    title="Input Waiting"
    body="Codex is waiting for your input."
    sound="IM"
else
    body="Event: ${event_name:-unknown}"
fi

if [ -z "$body" ]; then
    body="Codex notification"
fi

send_notification() {
    if ! command -v powershell.exe >/dev/null 2>&1; then
        return 0
    fi

    title_b64=$(echo -n "$title" | base64 -w 0)
    body_b64=$(echo -n "$body" | base64 -w 0)

    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
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

            if (\$isFocused) {
                exit 0;
            }
        }

        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null;
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null;

        \$title = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$title_b64'));
        \$body  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$body_b64'));
        \$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe';

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
    " >/dev/null 2>&1 || true
}

send_notification

if [ "$event_name" = "Stop" ]; then
    printf '{"continue":true}\n'
fi
