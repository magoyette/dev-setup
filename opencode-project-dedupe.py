#!/usr/bin/env python3
"""One-off: dedupe OpenCode project registrations caused by the nono sandbox
git-config denial.

Bug: while the nono sandbox denied reads of ~/.gitconfig, OpenCode's git
detection failed and it registered a second project row with vcs = NULL for
directories that already had a git-detected registration. Sessions attached to
the duplicate rows are invisible in the resume list because OpenCode scopes
sessions per project ID.

This script must run while every OpenCode process is stopped (client, server,
service). It checkpoints the WAL, takes a backup, then for every worktree with
multiple project rows keeps the git-detected row (or the one holding the most
children when no row has vcs = 'git'), re-points all child rows, and deletes
the duplicates.

Run:  python3 opencode-project-dedupe.py
Delete this file afterwards.
"""

from __future__ import annotations

import os
import sqlite3
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

DB_PATH = Path.home() / ".local" / "share" / "opencode" / "opencode.db"

# Tables with a plain project_id FK to project(id).
SIMPLE_CHILD_TABLES = ("session_v2", "session", "permission")
# Tables whose project_id FK is part of a composite primary key; the remaining
# columns are copied from the duplicate row to the keeper.
COMPOSITE_CHILD_TABLES = {
    "project_directory": ("directory", "type", "strategy", "time_created"),
    "worktree": ("directory", "strategy", "time_created"),
}


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    sys.exit(1)


def opencode_processes_alive() -> list[str]:
    """Return cmdlines of live processes that look like OpenCode."""
    hits: list[str] = []
    for pid_dir in Path("/proc").iterdir():
        if not pid_dir.name.isdigit():
            continue
        try:
            cmdline = (pid_dir / "cmdline").read_bytes().split(b"\0")
        except OSError:
            continue
        parts = [p.decode(errors="replace") for p in cmdline if p]
        joined = " ".join(parts)
        if not joined:
            continue
        # Skip this script itself (its own path contains "opencode-project-dedupe").
        if "project-dedupe" in joined:
            continue
        if "opencode" in joined:
            hits.append(f"[{pid_dir.name}] {joined}")
    return hits


def checkpoint(db: sqlite3.Connection) -> None:
    row = db.execute("PRAGMA wal_checkpoint(TRUNCATE)").fetchone()
    if row[0] != 0:
        fail(f"WAL checkpoint did not complete: {row}")


def backup(db: sqlite3.Connection, db_path: Path) -> Path:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    dest = db_path.with_name(f"{db_path.name}.backup-{stamp}")
    db.execute("VACUUM INTO ?", (str(dest),))
    return dest


def child_counts(db: sqlite3.Connection, project_id: str) -> int:
    total = 0
    for table in list(SIMPLE_CHILD_TABLES) + list(COMPOSITE_CHILD_TABLES):
        total += db.execute(
            f"SELECT COUNT(*) FROM {table} WHERE project_id = ?", (project_id,)
        ).fetchone()[0]
    return total


def duplicates_by_worktree(db: sqlite3.Connection) -> dict[str, list[str]]:
    rows = db.execute(
        """
        SELECT worktree, GROUP_CONCAT(id) FROM project
        GROUP BY worktree HAVING COUNT(*) > 1
        """
    ).fetchall()
    return {worktree: ids.split(",") for worktree, ids in rows}


def pick_keeper(db: sqlite3.Connection, ids: list[str]) -> tuple[str, list[str]]:
    """Keep the git-detected row; otherwise the one with the most children,
    breaking ties by earliest creation time."""
    rows = db.execute(
        """
        SELECT id, vcs, time_created FROM project WHERE id IN (%s)
        """
        % ",".join("?" * len(ids)),
        ids,
    ).fetchall()
    scored = []
    for project_id, vcs, created in rows:
        scored.append(
            (vcs == "git", child_counts(db, project_id), -created, project_id)
        )
    scored.sort(reverse=True)
    keeper = scored[0][3]
    return keeper, [i for i in ids if i != keeper]


def merge_duplicate(
    db: sqlite3.Connection, worktree: str, keeper: str, dupes: list[str]
) -> None:
    moved = 0
    for dup in dupes:
        for table in SIMPLE_CHILD_TABLES:
            cur = db.execute(
                f"UPDATE {table} SET project_id = ? WHERE project_id = ?", (keeper, dup)
            )
            moved += cur.rowcount
        for table, columns in COMPOSITE_CHILD_TABLES.items():
            col_list = ", ".join(columns)
            db.execute(
                f"""
                INSERT OR IGNORE INTO {table} ({col_list}, project_id)
                SELECT {col_list}, ? FROM {table} WHERE project_id = ?
                """,
                (keeper, dup),
            )
            db.execute(f"DELETE FROM {table} WHERE project_id = ?", (dup,))
        # Keep the most recent activity/updated stamps on the surviving row.
        db.execute(
            """
            UPDATE project SET
              time_active = MAX(time_active, (SELECT time_active FROM project WHERE id = ?)),
              time_updated = MAX(time_updated, (SELECT time_updated FROM project WHERE id = ?))
            WHERE id = ?
            """,
            (dup, dup, keeper),
        )
        db.execute("DELETE FROM project WHERE id = ?", (dup,))
    print(
        f"  {worktree}: kept {keeper}, removed {', '.join(dupes)} ({moved} sessions re-pointed)"
    )


def verify(db: sqlite3.Connection) -> None:
    integrity = db.execute("PRAGMA integrity_check").fetchone()[0]
    if integrity != "ok":
        fail(f"integrity_check failed: {integrity}")
    dupes = db.execute(
        "SELECT worktree FROM project GROUP BY worktree HAVING COUNT(*) > 1"
    ).fetchall()
    if dupes:
        fail(f"duplicate project rows remain: {dupes}")
    orphans = 0
    for table in list(SIMPLE_CHILD_TABLES) + list(COMPOSITE_CHILD_TABLES):
        orphans += db.execute(
            f"""
            SELECT COUNT(*) FROM {table} t
            LEFT JOIN project p ON p.id = t.project_id
            WHERE p.id IS NULL
            """
        ).fetchone()[0]
    if orphans:
        fail(f"{orphans} orphaned child rows reference missing projects")
    print("  integrity_check ok, no duplicate worktrees, no orphaned children")


def main() -> None:
    # Optional argv[1] overrides the DB path (used to test against a copy).
    db_path = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else DB_PATH
    if not db_path.is_file():
        fail(f"database not found: {db_path}")

    if db_path == DB_PATH:
        alive = opencode_processes_alive()
        if alive:
            print(
                "OpenCode appears to be running. Stop every instance first:",
                file=sys.stderr,
            )
            for line in alive:
                print(f"  {line}", file=sys.stderr)
            sys.exit(1)

    db = sqlite3.connect(db_path, isolation_level=None)
    db.row_factory = sqlite3.Row

    print(f"checkpointing WAL for {db_path} ...")
    checkpoint(db)

    dest = backup(db, db_path)
    print(f"backup written: {dest}")

    dupes = duplicates_by_worktree(db)
    if not dupes:
        print("no duplicate project registrations found; nothing to do")
        return

    print(f"found {len(dupes)} duplicated worktrees")
    db.execute("BEGIN IMMEDIATE")
    try:
        for worktree, ids in dupes.items():
            keeper, removed = pick_keeper(db, ids)
            merge_duplicate(db, worktree, keeper, removed)
        db.execute("COMMIT")
    except Exception:
        db.execute("ROLLBACK")
        fail("merge failed; transaction rolled back, database unchanged")

    print("verifying ...")
    verify(db)
    print("done. Start OpenCode and check the session resume list.")


if __name__ == "__main__":
    main()
