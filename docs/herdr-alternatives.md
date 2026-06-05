# Herdr Alternatives

Research recorded on 2026-05-31. Herdr remains the recommended tool for this setup because it directly supports Claude Code, Codex, and OpenCode integrations plus native agent session restore.

## Alternatives

- `dmux`: strong alternative for tmux and git worktree orchestration, but not a replacement for Herdr's general terminal/session layer.
  Sources: <https://dmux.ai/>, <https://github.com/standardagents/dmux>
- `gmux`: browser/mobile-first session manager for live terminal sessions; useful if remote browser access is the priority.
  Sources: <https://gmux.app/>, <https://github.com/gmuxapp/gmux>
- `webmux`: dashboard/worktree manager with PR, CI, Linear, and Docker sandbox features; larger workflow commitment than Herdr.
  Source: <https://webmux.dev/>
- `workmux`: tmux and git worktree workflow tool; useful for parallel branch work rather than agent state integration.
  Source: <https://github.com/raine/workmux>
- `rejoin`: session resume/search adjunct, not a live multiplexer replacement.
  Source: <https://github.com/therealchjones/rejoin>
- Generic `tmux`/`zellij`: reliable terminal multiplexers, but no built-in Claude/Codex/OpenCode semantic state or native restore integration.
