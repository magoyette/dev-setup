---
name: nono-sandbox-review
description: Review a session and document what the nono.sh sandbox denied — blocked commands and file accesses, why each was attempted, and the impact on the task. Excludes assistant permission prompts.
---

# nono.sh Sandbox Review

Report what the nono.sh sandbox blocked during a session, why those operations
were attempted, and what the denials cost the task. The review is
retrospective: it documents events that already happened. It does not change
sandbox policy.

## Scope

- Review the current session by default, or the session the user names.
- This skill documents nono.sh (Linux Landlock) denials. If the session runs
  under a different sandbox or no sandbox, say so and stop; do not substitute
  a review of another sandbox's limits.
- Base every finding on an event that occurred in the session. If the sandbox
  denied nothing, state that explicitly instead of inventing findings.

## What Counts As A Sandbox Denial

- Kernel `Permission denied` (`EACCES`) on a path with normal Unix
  permissions. Inside the sandbox this is the expected symptom of an ungranted
  path, not a filesystem problem. Common cases: `~/.ssh`, Windows mounts such
  as `/mnt/c`, repositories outside the launch directory, hardcoded `/tmp`
  paths (only the private `$TMPDIR` is granted), and the denied Herdr and
  Docker socket paths.
- Git fetching, pulling, pushing, or cloning a private repository failing with
  an authentication error. Credential helpers are unavailable by design
  inside the sandbox; local commits, branches, and diffs still work.
- The gh CLI aborting at startup (`failed to create root command`) because its
  token file is unreadable.
- File reads and edits on ungranted paths that failed with permission errors,
  not only shell commands.

## What Does Not Count

- Assistant permission prompts. The assistant's own approval workflow for
  tool calls — for example OpenCode asking permission to run a shell command —
  is a separate layer from the OS sandbox: an approved command still runs
  under the same sandbox limits. Never document permission prompts or approval
  dialogs in this review.
- Ordinary command failures: unknown commands, invalid arguments, failing
  tests, expected nonzero exit codes, missing files.
- Network errors. The managed profiles do not restrict network access, so do
  not attribute connection failures to the sandbox without a sandbox-specific
  error.

## Review Steps

1. Recall the session's failed commands and file accesses. Collect the
   candidates whose errors match a sandbox denial.
2. Verify each candidate. Confirm the error signature, or check the exact
   path and operation with `nono why`, using the session's profile
   (`opencode` for the managed dev-setup launcher):

   ```bash
   nono why --profile opencode --path "$HOME/.ssh/id_ed25519" --op read
   ```

   `--op` accepts `read`, `write`, or `readwrite`. The check is read-only and
   reports `ALLOWED` or `DENIED` with the policy reason. If it reports
   `ALLOWED` for the exact path and operation, the failure had another cause;
   exclude it or label it uncertain with the conflicting evidence.
3. For each confirmed denial, record why the operation was attempted and how
   the work continued: worked around (name the workaround), deferred to the
   user, verification skipped, or blocked. State the effect on the task's
   final result.
4. When the user asks for the sandbox's overall impact, also list the
   operations the session avoided without attempting because the sandbox
   denies them by design — for example authenticated Git pushes deferred to
   the user. Label them as avoided, not denied, and keep them separate from
   the failed commands.

## Report Format

Order findings by impact on the task. For each finding:

- **Attempted:** the command or file access, quoted from the session.
- **Denial:** the observed error or behavior.
- **Why:** the task need that justified the attempt.
- **Impact:** how the work continued and the effect on the result.

Close with a short summary: the denials, the workarounds adopted, and any
outcome that changed because of the sandbox. When the user wants to prevent a
denial in future sessions, name the narrowest grant that would allow it — a
single file read-only beats a directory, and a directory read-only beats
read/write — but do not apply grants or profile changes as part of the review.

## Guardrails

- Quote the actual error messages from the session. If it stays unclear
  whether the sandbox caused a failure, label the finding as uncertain
  instead of asserting it.
- Do not retry denied operations or attempt bypasses (`chmod`, `sudo`,
  hardcoded `/tmp` paths). The kernel denies them regardless of file
  permissions.
- Report only. Do not modify the sandbox profile or request new grants during
  the review.
