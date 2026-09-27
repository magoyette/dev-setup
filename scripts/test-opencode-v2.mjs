import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, writeFileSync, chmodSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";
import notifications from "../opencode-plugins/crit/tui.js";
import { isCritWaitCommand } from "../opencode-plugins/crit/wait-notify.js";

const root = resolve(import.meta.dirname, "..");

test("Crit notifications correlate shell events and unsubscribe on unload", () => {
  for (const command of ["crit", "crit README.md", "FOO=bar crit --pr 12", "./crit live http://localhost:3000"]) {
    assert.equal(isCritWaitCommand(command), true);
  }
  for (const command of ["crit share x.md", "crit comment x.md", "crit config", "echo crit", undefined]) {
    assert.equal(isCritWaitCommand(command), false);
  }
  let receive;
  let stopped = false;
  const toasts = [];
  const dispose = notifications.setup({
    data: { listen: (fn) => { receive = fn; return () => { stopped = true; }; } },
    ui: { toast: { show: (toast) => toasts.push(toast) } },
  });
  const send = (type, data) => receive({ details: { type, data } });
  send("session.tool.input.started", { sessionID: "one", id: "tool", name: "shell" });
  send("session.tool.called", { sessionID: "two", id: "tool", input: { command: "crit" } });
  assert.equal(toasts.length, 0);
  send("session.tool.called", { sessionID: "one", id: "tool", input: { command: "crit" } });
  assert.equal(toasts.length, 1);
  assert.equal(toasts[0].title, "Crit");
  dispose();
  assert.equal(stopped, true);
});

test("V2 merge preserves unrelated config and plugin order, reconciles MCPs, and is idempotent", () => {
  const dir = mkdtempSync(`${tmpdir()}/opencode-merge-test-`);
  try {
    const path = `${dir}/opencode.json`;
    writeFileSync(path, JSON.stringify({
      model: "custom/example", provider: { custom: { options: { custom: true } } },
      snapshot: true, lsp: true,
      plugin: ["z-first", ["a-second", { custom: true }], "./plugins/crit.ts"],
      mcp: {
        managed: { type: "remote", url: "https://old.invalid" },
        other: { type: "local", command: ["custom-server"] },
        servers: { managed: { type: "remote", url: "https://old-native.invalid" }, native: { type: "local", command: ["native-server"] } },
        timeout: { execution: 1234 },
      },
    }));
    const env = { ...process.env, AI_ASSISTANTS_MCP_CATALOG: JSON.stringify({ managed: { url: "https://new.invalid" } }), AI_ASSISTANTS_MCPS: '["managed"]' };
    const merge = () => spawnSync("bash", [`${root}/scripts/merge-opencode-config.sh`, path], { env, encoding: "utf8" });
    assert.equal(merge().status, 2);
    const config = JSON.parse(readFileSync(path));
    assert.equal(config.model, "custom/example");
    assert.deepEqual(config.provider, { custom: { options: { custom: true } } });
    assert.deepEqual(config.plugins, ["z-first", { package: "a-second", options: { custom: true } }, "./crit-opencode"]);
    assert.equal(config.snapshots, false);
    assert.equal(config.snapshot, undefined);
    assert.equal(config.lsp, undefined);
    assert.equal(config.permission, undefined);
    assert.equal(config.mcp.managed, undefined);
    assert.equal(config.mcp.servers.managed.url, "https://new.invalid");
    assert.equal(config.mcp.other.command[0], "custom-server");
    assert.equal(config.mcp.servers.native.command[0], "native-server");
    assert.equal(config.mcp.timeout.execution, 1234);
    assert.ok(config.permissions.some((p) => p.action === "shell" && p.resource === "git push *" && p.effect === "deny"));
    assert.deepEqual(config.permissions.filter((p) => p.action === "read").map((p) => p.effect), ["allow", "deny", "deny", "allow"]);
    assert.equal(merge().status, 0);
    env.AI_ASSISTANTS_MCPS = "[]";
    assert.equal(merge().status, 2);
    assert.equal(JSON.parse(readFileSync(path)).mcp.servers.managed, undefined);
    assert.equal(merge().status, 0);
    writeFileSync(path, "not JSON");
    assert.equal(merge().status, 1);
    assert.equal(readFileSync(path, "utf8"), "not JSON");
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test("launcher selects private servers and keeps offline subcommands valid", () => {
  const dir = mkdtempSync(`${tmpdir()}/opencode-launcher-test-`);
  try {
    const helper = `${dir}/dev-setup-ai-assistant-sandbox`;
    writeFileSync(helper, '#!/bin/sh\nprintf "%s\\n" "$@"\n');
    chmodSync(helper, 0o755);
    const run = (args) => spawnSync("bash", [`${root}/ai-assistant-launchers/.local/bin/opencode`, ...args], {
      env: { ...process.env, PATH: `${dir}:${process.env.PATH}`, DEV_SETUP_REAL_OPENCODE: "/bin/true" }, encoding: "utf8",
    });
    for (const args of [[], ["run", "a prompt"], ["models"], ["session", "list"], ["auth", "list"], ["--log-level", "debug", "run", "prompt"], ["--prompt", "debug"]]) {
      const result = run(args);
      assert.equal(result.status, 0, result.stderr);
      assert.ok(result.stdout.includes("--standalone\n"), JSON.stringify(args));
    }
    for (const args of [["debug", "paths"], ["plugin", "list"], ["mcp", "list"], ["--log-level", "debug", "debug", "config"]]) {
      const result = run(args);
      assert.equal(result.status, 0);
      assert.ok(!result.stdout.includes("--standalone\n"));
    }
    assert.equal(run(["--standalone=false"]).status, 2);
    assert.equal(run(["run", "--server=http://localhost:4096"]).status, 2);
    assert.equal(run(["run", "--", "--server"]).status, 0);
    const nested = run(["--log-level", "error", "auth", "list"]).stdout;
    assert.ok(nested.includes("auth\nlist\n--standalone\n"));
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});
