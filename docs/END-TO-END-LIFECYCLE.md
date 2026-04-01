# UX Collab: End-to-End Lifecycle Guide

Complete guide for running the entire UX collaboration workflow from setup to deployment.

---

## Table of Contents

1. [Initial Setup](#1-initial-setup)
2. [Project Configuration](#2-project-configuration)
3. [Daily Workflow](#3-daily-workflow)
4. [The 8-Step Loop in Practice](#4-the-8-step-loop-in-practice)
5. [Integration with Design Systems](#5-integration-with-design-systems)
6. [Troubleshooting](#6-troubleshooting)
7. [Best Practices](#7-best-practices)

---

## 1. Initial Setup

### Install the Skill

Choose your agent platform:

**Pi / skills.sh (Recommended):**
```bash
npx skills add kylebrodeur/ux-collab
```

**Claude Code:**
```bash
# Add marketplace once
claude plugin marketplace add kylebrodeur/ux-collab

# Install plugin
claude plugin install ux-collab@ux-collab
```

**GitHub Copilot:**
```bash
# Copy the copilot configuration to your project
mkdir -p .github/agents
cp ~/.agents/skills/ux-collab/.github/copilot.json .github/agents/
```

**Manual (any agent):**
```bash
# Clone to skills directory
git clone https://github.com/kylebrodeur/ux-collab.git ~/.agents/skills/ux-collab
```

### Install Dependencies

Navigate to your project and run setup:

```bash
cd your-project

# If you cloned ux-collab directly:
cd path/to/ux-collab
npm install
npm run setup

# Or run the setup script directly:
bash ~/.agents/skills/ux-collab/scripts/setup.sh
```

The setup script will:
- Install `agent-browser` (if not present)
- Install ImageMagick for screenshot optimization
- Create `.ux-collab.md` config file
- Verify everything is working

### Verify Installation

```bash
npm run check
```

Expected output:
```
✔ agent-browser installed
✔ ImageMagick installed
✔ .ux-collab.md present
```

---

## 2. Project Configuration

### Create `.ux-collab.md`

This file tells the agent about your project structure:

```yaml
# UX Collab — Project Config
defaultUrl: http://localhost:3000
decisionsDoc: docs/DESIGN_DECISIONS.md

# Figma (optional - for design system sync)
figmaFileUrl: https://www.figma.com/design/YOUR_FILE/your-design-system
codeConnectEnabled: true

# Token files
targetFiles:
  tokens: app/globals.css          # Your CSS variables
  components: app/_components/        # Component directory

# Surfaces your app has (for quick navigation)
surfaces:
  - name: Homepage
    route: /
  - name: Dashboard
    route: /dashboard
  - name: Settings
    route: /settings

# Design decisions being tracked
openDecisions:
  - "Product browser format: grid vs list vs journey"
  - "Survey UX pattern: scroll vs stepped"
```

### Optional: Configure MCP Tools

For Figma integration, create `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@figma/mcp"],
      "env": { "FIGMA_API_KEY": "figd_your_key_here" }
    },
    "lucid": {
      "command": "npx",
      "args": ["@lucid/mcp@latest"]
    }
  }
}
```

> **Note:** MCP configs are per-project. The skill will check for these automatically.

---

## 3. Daily Workflow

### Starting a Design Session

**Tell your agent:**
> "Let's work on the UI"

Or be specific:
> "Show me what the dashboard looks like"
> "Create a wireframe for the new feature"

The agent will:
1. Check prerequisites (agent-browser, ImageMagick)
2. Open your dev server
3. Take a baseline screenshot
4. Start the 8-step loop

### Running the Check

Before any session, the agent (or you) should run:

```bash
npm run check
```

This verifies:
- agent-browser is installed and ready
- ImageMagick is available
- MCP tools are configured (if present)
- `.ux-collab.md` exists

---

## 4. The 8-Step Loop in Practice

### SEE (Baseline)

**Agent actions:**
```bash
# Open default URL from .ux-collab.md
agent-browser open http://localhost:3000

# Take screenshot
agent-browser snapshot -o /tmp/screenshots/baseline.png

# Optimize for chat
~/.agents/skills/ux-collab/optimize-screenshot.sh /tmp/screenshots/baseline.png
```

**Output:** Optimized screenshot attached to conversation.

### DISCUSS (Design Questions)

**Agent asks:**
- "What do you see that needs to change?"
- "What's the primary action on this screen?"
- "Are there any open decisions from last time?"

**You respond:**
- Point out specific issues
- Reference previous decisions
- Define scope for this session

### IDEATE (Wireframes - Optional)

**When to use:** New layouts, structural changes, stakeholder review

**With Lucid MCP:**
```
Agent: "I'll create a wireframe"
→ mcp_lucid_create_diagram_from_specification
→ Share link to kyle@uof.digital
→ Export image back to conversation
```

**Without Lucid:**
```
Agent creates Markdown wireframe:
```
┌─────────────────────────────────┐
│  [Header: Logo + Nav]           │
│  bg-brand-navy                  │
├─────────────────────────────────┤
│                                 │
│  [Hero Section]                 │
│  H1: Value proposition          │
│  CTA: Primary button            │
│                                 │
└─────────────────────────────────┘
```

### SPECIFY (Figma - Optional)

**When to use:** Component specs, token verification, Code Connect

**Agent queries Figma:**
```
mcp_figma_get_variable_defs    → Pull design tokens
mcp_figma_get_design_context   → Get React component code + variant props
mcp_figma_search_design_system → Find existing components
```

**Verify implementation:**
- Compare screenshot to Figma design
- Check token usage matches spec
- Validate component structure

### BUILD (Implementation)

**Agent writes code with constraints:**
- Uses tokens from `targetFiles.tokens`
- Applies brand values from `.ux-collab.md`
- Follows patterns in `components/CLAUDE.md`

**Example output:**
```tsx
// Button component with brand tokens
<button className="bg-brand-navy text-white px-4 py-2 rounded-none">
  {children}
</button>
```

### VERIFY (Compare)

**Agent actions:**
```bash
# Rebuild and screenshot
npm run build  # or pnpm dev
agent-browser reload
agent-browser snapshot -o /tmp/screenshots/after.png

# Compare
"[Attached: before.png] → [Attached: after.png]"
"Changed: button now uses brand-navy"
"Still needed: adjust padding to match spec"
```

### SYNC (Design Decisions)

**Update decisions document:**
```markdown
## Resolved 2026-03-31
- **Button color** → brand-navy. Rationale: matches design system.
- **Border radius** → 0px (square-first system).
```

### RECORD (Documentation)

**Agent updates:**
- `docs/DESIGN_DECISIONS.md` (or your configured `decisionsDoc`)
- Screenshots in `docs/screenshots/`
- Component documentation

---

## 5. Integration with Design Systems

### With Code-to-Figma

Sync React components to Figma:

```bash
# Scan component
npx @kylebrodeur/code-to-figma scan app/_components/Button.tsx

# Output goes to .figma/Button.figma.json

# Import in Figma plugin
# Plugins → Code to Figma → Import JSON
```

See [code-to-figma documentation](https://github.com/kylebrodeur/code-to-figma)

### With Agent-Browser Skills

For advanced browser automation:

```bash
# Install agent-browser core skill
npx skills add vercel-labs/agent-browser --skill agent-browser
```

This enables:
- Session persistence
- Multi-page workflows
- Authentication flows
- Diffing capabilities

See [agent-browser skills](https://agent-browser.dev/skills)

---

## 6. Troubleshooting

### agent-browser not found
```bash
# Install via brew (macOS - fastest)
brew install agent-browser
agent-browser install  # Download Chrome

# Or via npm
npm install -g agent-browser
agent-browser install
```

### ImageMagick not found
```bash
# macOS
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick

# Windows (WSL)
sudo apt-get install imagemagick
```

### MCP tools not connecting
1. Check `.mcp.json` exists in project root
2. Verify API keys are set
3. Restart agent session
4. Try: `npx @kylebrodeur/mcp-wsl-setup` (for WSL path issues)

### Screenshots too large
The `optimize-screenshot.sh` script should run automatically. If not:
```bash
~/.agents/skills/ux-collab/optimize-screenshot.sh /path/to/screenshot.png
```

### Dev server not running
```bash
# From .ux-collab.md defaultUrl, agent detects if unreachable
# It will suggest running:
npm run dev
# or
pnpm dev
```

---

## 7. Best Practices

### Before Each Session
- [ ] Run `npm run check`
- [ ] Dev server is running
- [ ] Review open decisions from last session
- [ ] Confirm which surface you're working on

### During Design
- Start with screenshots, not code
- Wireframe structural changes before building
- Use brand tokens, never hardcoded values
- Verify after every meaningful change

### After Each Session
- Update `decisionsDoc` with resolved items
- Commit screenshots showing before/after
- Note any still-open decisions

### Project Hygiene
- Keep `.ux-collab.md` updated with new surfaces
- Document design decisions in one place
- Use the 8-step loop consistently
- Reference agent-browser skills for complex browser tasks

---

## Quick Reference

**Commands:**
```bash
npm run setup      # One-time setup
npm run check      # Verify dependencies
npm run optimize-screenshot <file>  # Optimize PNG
```

**Trigger Phrases:**
- "Let's work on the UI"
- "Show me what it looks like"
- "Create a wireframe"
- "Take a screenshot"
- "Verify the changes"

**Files:**
- `.ux-collab.md` — Project config
- `docs/DESIGN_DECISIONS.md` — Decision log
- `CLAUDE.md` — Project governance

---

## Support

- GitHub Issues: https://github.com/kylebrodeur/ux-collab/issues
- Documentation: https://github.com/kylebrodeur/ux-collab

---

## License

MIT © Kyle Brodeur
