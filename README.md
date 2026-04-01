# UX Collab v2.2.0

Visual-first UI/UX collaboration for AI agents — agent-browser + Figma MCP + Lucid. Turn wireframes into production code that matches your design system.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Quick Start

```bash
# Install dependencies
npm install

# One-command setup
npm run setup

# Verify
npm run check
```

Then tell your agent: **"Let's work on the UI"**

---

## The 8-Step Loop

```
SEE → DISCUSS → IDEATE → SPECIFY → BUILD → VERIFY → SYNC → RECORD
        ↑___________↓___________________________↓
           (Lucid)          (Figma + Code Connect)
```

| Phase | Tool | Purpose |
|-------|------|---------|
| **IDEATE** | Lucid | Rough wireframes, layout exploration |
| **SPECIFY** | Figma MCP | Component specs, token verification, Code Connect |
| **BUILD** | Local + agent-browser | Implementation with real tokens |
| **VERIFY** | agent-browser + Figma MCP | Screenshot comparison, token compliance |

---

## Tool Roles

| Tool | When to Use |
|------|-------------|
| **agent-browser** (primary) | Screenshots, browser automation, verification — fast, no MCP setup |
| **Figma MCP** | Component specs, design tokens, Code Connect integration — production accuracy |
| **Lucid** | Quick wireframes, ideation, stakeholder communication — layout exploration |
| **Playwright MCP** | Complex accessibility trees, device emulation — when agent-browser limits |

**Decision**: New rough idea → **Lucid**. Component specs → **Figma**. Everything else → **agent-browser**.

---

## Installation

### 1. Pi / skills.sh
```bash
npx skills add kylebrodeur/ux-collab
```

### 2. Claude Code
```bash
# Add marketplace
claude plugin marketplace add kylebrodeur/ux-collab

# Install plugin
claude plugin install ux-collab@ux-collab
```

### 3. GitHub Copilot
Copy `.github/copilot.json` to your `.github/agents/` folder.

### 4. Manual
```bash
cp -r skills/ux-collab ~/.agents/skills/
```

---

## Configuration (Optional)

Create `.ux-collab.md` in your project root:

```yaml
# UX Collab — Project Config
defaultUrl: http://localhost:3000
decisionsDoc: docs/DESIGN_DECISIONS.md

# Figma (optional)
figmaFileUrl: https://www.figma.com/design/ABC123/your-file
codeConnectEnabled: true

# Tokens
targetFiles:
  tokens: src/styles/tokens.css
  components: src/components/

surfaces:
  - name: Homepage
    route: /
  - name: Dashboard
    route: /dashboard
```

---

## Figma MCP Setup (Optional)

Add to your `.mcp.json`:

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@figma/mcp"],
      "env": { "FIGMA_API_KEY": "your-api-key" }
    }
  }
}
```

**MCP Commands** (when available):
- `mcp_figma_get_variable_defs` — Pull design tokens
- `mcp_figma_get_design_context` — Get Code Connect snippets + variant props
- `mcp_figma_get_screenshot` — Capture Figma designs
- `mcp_figma_search_design_system` — Find components

See [Figma Integration Guide](skills/ux-collab/figma-integration.md) for full workflow.

---

## Repository Layout

```
ux-collab/
├── skills/ux-collab/
│   ├── SKILL.md              # Main skill documentation
│   ├── figma-integration.md  # Figma MCP workflow guide
│   └── optimize-screenshot.sh
├── scripts/
│   ├── setup.sh              # One-command install
│   └── check.sh              # Verify dependencies
├── CLAUDE.md                 # Project governance template
├── styles/CLAUDE.md          # Token validation rules
├── components/CLAUDE.md      # Component requirements
└── example/                  # Full workflow demo
```

---

## Full Workflow Example

See [`example/WORKFLOW.md`](example/WORKFLOW.md) for step-by-step demo:
1. Wireframe in Lucid
2. Component specs from Figma via Code Connect
3. Build with agent-browser
4. Verify with screenshot comparison
5. Sync decisions

---

## License

MIT
