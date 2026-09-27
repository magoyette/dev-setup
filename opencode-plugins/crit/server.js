import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execute = promisify(execFile);
const sharing = `## Sharing

When the user requests a shareable review link, run crit share <file> and relay
the resulting URL. Use crit share --qr <file> only in terminals. Use
crit unpublish <file> to remove a shared review using its persisted token.
`;

export default {
  id: "dev-setup.crit",
  async setup(ctx) {
    let enabled;
    await ctx.session.hook("context", async (event) => {
      if (enabled === undefined) {
        try {
          const { stdout } = await execute("crit", ["config"]);
          enabled = Boolean(JSON.parse(stdout).share_url);
        } catch {
          enabled = false;
        }
      }
      if (enabled) event.system.push({ type: "text", text: sharing });
    });
  },
};
