---
name: ux-collab-setup
description: "Install and configure all ux-collab dependencies. Use when: setting up ux-collab for the first time, something isn't working, check.sh reports failures, Playwright MCP is missing, ImageMagick is missing, or the user asks to 'set up ux-collab', 'fix the dependencies', or 'get ux-collab ready'."
compatibility: "Requires bash. ImageMagick auto-installed on macOS (brew) and Ubuntu/Debian (apt). Playwright and Lucid MCP require manual steps guided by this skill."
license: MIT
metadata:
  author: kylebrodeur
  version: "1.0"
---

# UX Collab Setup Skill

Diagnose and fix missing ux-collab dependencies in one guided session.

## Step 1 — Run the check

Find the package root and run the check script:

```bash
# From the package directory:
bash scripts/check.sh

# Or if installed globally / via npx:
npx ux-collab check
```

Read the output carefully. Each line is either ✔ (pass), ⚠ (warning/optional), or ✘ (required — must fix).

## Step 2 — Auto-fix what can be automated

Run setup.sh — it handles ImageMagick installation and creates `.ux-collab.md` if missing:

```bash
bash scripts/setup.sh
```

This will:
- Install ImageMagick via `brew` (macOS) or `apt` (Ubuntu/Debian) if missing
- Make `optimize-screenshot.sh` executable
- Copy `optimize-screenshot.sh` to `~/.agents/skills/ux-collab/` if the skill is installed there
- Create a starter `.ux-collab.md` in the current directory if none exists
- Re-run `check.sh` at the end to confirm

## Step 3 — Fix Playwright MCP (if still failing)

Playwright MCP is required and cannot be auto-installed. Follow the right path for the agent harness in use:

### Claude Code (plugin system)

```bash
claude plugin install playwright@claude-plugins-official
```

Then restart Claude Code. Re-run `bash scripts/check.sh` to confirm.

### If MCP servers start but hang or show pnpm path errors

This is a known issue on WSL and macOS when pnpm is managed via fnm or a non-standard path. Use the appropriate fixer:

```bash
npx @kylebrodeur/mcp-wsl-setup   # WSL (fixes fnm/pnpm paths in VS Code mcp.json)
npx @kylebrodeur/mcp-mac-setup   # macOS (fixes pnpm paths)
```

Re-run `bash scripts/check.sh` after.

### Any harness (manual MCP server via `.mcp.json`)

Create or edit `.mcp.json` in the project root:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Restart the agent session. Re-run `bash scripts/check.sh` to confirm.

## Step 4 — Fix Lucid MCP (optional — skip if not needed)

Lucid MCP enables diagram creation in Step 3 of the ux-collab loop. Without it, the skill falls back to Markdown wireframes automatically — **this is not a blocker**.

To enable Lucid wireframes:

```bash
# Claude Code:
claude plugin install lucid@claude-plugins-official

# Or add to .mcp.json:
# "lucid": { "command": "npx", "args": ["@lucid/mcp@latest"] }
```

## Step 5 — Create project config (if warned)

If `check.sh` warned that `.ux-collab.md` is missing, create one:

```bash
node cli.cjs init
# or
npx ux-collab init
```

Then edit `.ux-collab.md` to set:
- `defaultUrl` — your dev server URL
- `lucidShareEmail` — your Lucid account email
- Brand tokens, target files, and surfaces (see [docs/project-setup.md](../ux-collab/docs/project-setup.md))

## Step 6 — Final verification

```bash
bash scripts/check.sh
```

Expected output when fully ready:
```
✔ Passed:   5+
⚠ Warnings: 0–2  (Lucid and .ux-collab.md are optional)
✘ Failed:   0
→ All required dependencies present. Ready to run ux-collab.
```

If any ✘ remain, re-read the "Issues to fix" section printed by the script and follow the instructions there.

## Quick reference — what each dep does

| Dep | Why it's needed |
|-----|----------------|
| Node.js ≥20 | Runs `cli.cjs` and any MCP servers launched via npx |
| ImageMagick `convert` + `identify` | Resizes and compresses Playwright screenshots before attaching to chat |
| Playwright MCP (`mcp_playwright_*`) | Takes screenshots, navigates, clicks, resizes viewport — the eyes of the ux-collab loop |
| Lucid MCP (`mcp_lucid_*`) | Creates and exports wireframe diagrams — optional, Markdown fallback used when absent |
| `.ux-collab.md` | Per-project config: dev URL, brand tokens, file targets, open decisions |
