import type { HookAPI } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";

// Shmorch safety hook — the omp equivalent of .claude/hooks/pre-tool.sh.
// Blocks destructive shell commands before they run. On CLIs with no hook
// system, the model still enforces the Safety Rules in shmorch-core.md.
const BLOCKED = /rm\s+-rf|rm\s+-r\s+\/|git\s+push\s+--force|git\s+push\s+-f(\s|$)/;

export default function (pi: HookAPI): void {
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return;
    // event.input.command is unknown here; String(... ?? "") narrows without a cast.
    const command = String(event.input?.command ?? "");
    if (BLOCKED.test(command)) {
      return {
        block: true,
        reason: "Shmorch: destructive op blocked — confirm with the user first.",
      };
    }
  });
}
