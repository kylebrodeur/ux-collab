# UX Collab

Visual-first UI/UX collaboration skill for Claude Code and GitHub Copilot. Take live screenshots of your running app, produce Lucid wireframes or Markdown fallback wireframes, and run a structured design→build→verify loop.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-4183C4)](https://claude.ai/code)
[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Compatible-4183C4)](https://github.com/features/copilot)
[![Pi](https://img.shields.io/badge/Pi-Compatible-4183C4)](https://github.com/badlogic/pi-coding-agent)
[![skills.sh](https://img.shields.io/badge/skills.sh-Compatible-4183C4)](https://skills.sh)

---

## What It Does

The `ux-collab` skill gives your AI agent a structured visual-first workflow:

```
SEE → DISCUSS → DESIGN → BUILD → VERIFY → RECORD
```

| Step | What happens |
|------|-------------|
| **SEE** | Navigate to live app, take screenshot, optimize it, snapshot accessibility tree |
| **DISCUSS** | Synthesize observations into exactly one focused design question |
| **DESIGN** | Produce a Lucid wireframe (or Markdown fallback when Lucid isn't available) |
| **BUILD** | Implement only what was agreed — no scope creep |
| **VERIFY** | Reload, screenshot, compare before/after, run accessibility audit |
| **RECORD** | Update decisions doc with resolved choices + rationale |

### Requirements

| Tool | Required | Notes |
|------|----------|-------|
| Playwright MCP | ✅ Yes | `mcp_playwright_*` tools |
| ImageMagick | ✅ Yes | `convert` + `identify` CLI commands |
| Lucid MCP | ⚡ Optional | Falls back to Markdown wireframes |

Install ImageMagick if needed:
```bash
brew install imagemagick          # macOS
sudo apt install imagemagick      # Ubuntu / Debian
```

---

## Installation

### Pi (skills.sh)

```bash
npx skills add kylebrodeur/ux-collab
```

### Claude Code Plugin

```bash
claude plugin marketplace add kylebrodeur/ux-collab
claude plugin install ux-collab@ux-collab
```

Or manually copy the `skills/` folder:
```bash
cp -r skills/ux-collab ~/.agents/skills/
```

### GitHub Copilot Plugin

```bash
copilot plugin install kylebrodeur/ux-collab
```

Or copy the agent definition manually to your project:
```bash
mkdir -p .github/agents
cp .github/copilot.json .github/agents/ux-collab.json
```

### Manual (any agent)

Copy the skill directory to wherever your agent loads skills from:
```bash
cp -r skills/ux-collab ~/.agents/skills/
# or
cp -r skills/ux-collab .agents/skills/
```

---

## Project Setup

The skill is project-agnostic by default. To configure it for your specific app, drop a `.ux-collab.md` file at your project root:

```markdown
# UX Collab — Project Config

## Settings

- **defaultUrl**: http://localhost:3000
- **decisionsDoc**: docs/DESIGN_DECISIONS.md
- **lucidShareEmail**: you@example.com

## Brand Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `--brand-primary` | `#0D1B2A` | Headings, primary bg |
| `--brand-accent` | `#F5A623` | CTAs, highlights |

## Target Files

- `app/_components/` — UI components
- `app/globals.css` — token layer
- `tailwind.config.ts` — token wiring

## Open Design Decisions

1. Navigation pattern — sidebar vs. top nav
2. Mobile layout — stacked vs. scrollable columns
```

See [skills/ux-collab/docs/project-setup.md](skills/ux-collab/docs/project-setup.md) for the full schema.

---

## Usage

Once installed, trigger the skill with natural language:

- *"Let's work on the UI"*
- *"Show me what the dashboard looks like"*
- *"Create a wireframe for the onboarding flow"*
- *"Take a screenshot and review the layout"*
- *"Before we build this, let's decide on the pattern"*

In pi, you can also invoke it directly:
```bash
/skill:ux-collab
```

---

## Optimize Screenshot Script

The `optimize-screenshot.sh` script is bundled with the skill. It converts raw Playwright PNGs (often 280KB+) to optimized JPEGs under 80KB — keeping context window usage low.

```bash
# Auto-finds latest screenshot:
./skills/ux-collab/optimize-screenshot.sh

# Or optimize a specific file:
./skills/ux-collab/optimize-screenshot.sh /path/to/screenshot.png
```

Output is written to `/tmp/playwright-screenshots-optimized/`.

---

## Repository Layout

```
ux-collab/
├── README.md
├── package.json
├── LICENSE
├── .clinerules                        # Claude Code agent rules
├── .claude-plugin/
│   └── plugin.json                    # Claude Code Marketplace manifest
├── .github/
│   ├── copilot.json                   # GitHub Copilot agent definition
│   ├── skill-index.json               # Discovery index (both harnesses)
│   └── plugin/
│       └── plugin.json                # Copilot plugin manifest
└── skills/
    └── ux-collab/
        ├── SKILL.md                   # The skill (project-agnostic)
        ├── optimize-screenshot.sh     # Screenshot optimization helper
        └── docs/
            └── project-setup.md      # .ux-collab.md config guide
```

---

## License

MIT
