import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Pi loads Superpowers packages through `pi -e`, but the shared Crit
// companion needs its own Pi package wrapper so Pi can discover the Crit skill
// directory and receive the same validation prompt used by other assistants.
const MARKER = "dev-setup Superpowers Crit validation companion for Pi";

const extensionDir = dirname(fileURLToPath(import.meta.url));
const packageRoot = resolve(extensionDir, "../..");
const skillsDir = resolve(packageRoot, "skills");
const instructionsPath = resolve(packageRoot, "instructions.md");

let cachedInstructions: string | null | undefined;

export default function superpowersCritPiExtension(pi: ExtensionAPI) {
	let injectInstructions = true;

	// Expose the Crit validation skill to Pi's skill discovery for this session.
	pi.on("resources_discover", async () => ({
		skillPaths: [skillsDir],
	}));

	pi.on("session_start", async () => {
		injectInstructions = true;
	});

	pi.on("session_compact", async () => {
		injectInstructions = true;
	});

	pi.on("agent_end", async () => {
		injectInstructions = false;
	});

	pi.on("context", async (event) => {
		if (!injectInstructions) return;
		if (event.messages.some(messageContainsMarker)) return;

		const instructions = getInstructions();
		if (!instructions) return;

		// Inject once per active agent turn so Pi gets the Superpowers Crit
		// review requirement even when the package is loaded only for `pi-sp`.
		const instructionMessage = {
			role: "user" as const,
			content: [
				{
					type: "text" as const,
					text: `<EXTREMELY_IMPORTANT>\n${MARKER}\n\n${instructions}\n</EXTREMELY_IMPORTANT>`,
				},
			],
			timestamp: Date.now(),
		};

		return {
			messages: [instructionMessage, ...event.messages],
		};
	});
}

function getInstructions(): string | null {
	if (cachedInstructions !== undefined) return cachedInstructions;

	try {
		cachedInstructions = readFileSync(instructionsPath, "utf8").trim();
		return cachedInstructions;
	} catch {
		cachedInstructions = null;
		return null;
	}
}

function messageContainsMarker(message: unknown): boolean {
	const content = (message as { content?: unknown }).content;
	if (typeof content === "string") return content.includes(MARKER);
	if (!Array.isArray(content)) return false;
	return content.some((part) => {
		return (
			part &&
			typeof part === "object" &&
			(part as { type?: unknown }).type === "text" &&
			typeof (part as { text?: unknown }).text === "string" &&
			(part as { text: string }).text.includes(MARKER)
		);
	});
}
