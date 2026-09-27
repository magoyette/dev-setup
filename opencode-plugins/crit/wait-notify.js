// ESM counterpart of Crit's generated plugins/lib/crit-wait-notify.js.
// OpenCode 2's CLI plugin loader does not load that CommonJS helper.
const nonWait = new Set([
  "help", "--help", "-h", "--version", "-v", "version", "share", "fetch",
  "unpublish", "install", "config", "check", "pr", "pull", "push", "comment",
  "comments", "plan-hook", "story", "auth", "stop", "status", "stats", "cleanup", "_serve",
]);

export function isCritWaitCommand(command) {
  if (typeof command !== "string") return false;
  const text = command.trim().replace(/^(?:[A-Za-z_][A-Za-z0-9_]*=\S*\s+)+/, "");
  if (!/^(?:\.\/)?crit(?:\s|$)/.test(text)) return false;
  const first = text.replace(/^(?:\.\/)?crit\s*/, "").trim().split(/\s+/)[0];
  return !nonWait.has(first);
}

export function roundReadyToast() {
  return {
    title: "Crit",
    message: "Review ready — check your browser and click Finish Review when done.",
  };
}
