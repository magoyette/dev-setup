import { isCritWaitCommand, roundReadyToast } from "./wait-notify.js";

export default {
  id: "dev-setup.crit.notifications",
  setup(ctx) {
    const tools = new Map();
    const stop = ctx.data.listen(({ details: event }) => {
      const data = event.data;
      if (!data) return;
      const key = `${data.sessionID}:${data.id}`;
      if (event.type === "session.tool.input.started") {
        tools.set(key, data.name);
      } else if (event.type === "session.tool.called") {
        const name = tools.get(key);
        tools.delete(key);
        if (name !== "shell" && name !== "bash") return;
        if (!isCritWaitCommand(data.input?.command ?? data.input?.cmd)) return;
        ctx.ui.toast.show({ ...roundReadyToast(), variant: "info" });
      } else if (event.type === "session.tool.failed" || event.type === "session.tool.success") {
        tools.delete(key);
      }
    });
    return () => {
      stop();
      tools.clear();
    };
  },
};
