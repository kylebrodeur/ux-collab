---
name: ux-collab
description: "Visual-first UI/UX collaboration loop using agent-browser (primary), Playwright MCP (alternative), Figma MCP (design system/specs), and Lucid (wireframes). Use when designing or iterating on UI, reviewing the live app visually, creating wireframes, making layout decisions, discussing design before building, or running a design→build→verify loop. Trigger phrases: 'let's work on the UI', 'show me what it looks like', 'create a wireframe', 'design the layout', 'take a screenshot', 'browser view', 'before we build let's decide'."
compatibility: "Requires: agent-browser (brew/npm) OR Playwright MCP (mcp_playwright_*). ImageMagick for screenshot optimization. Optional: Lucid MCP (wireframes), Figma MCP (design tokens/component specs)."
license: MIT
metadata:
  author: kylebrodeur
  version: "2.2"
---

# UX Collaboration Skill

A structured loop for visual-first UI/UX design and implementation. Works with any web app running locally — project-specific routes, surfaces, and brand tokens are configured per-project via `.ux-collab.md` (see [Project Setup](docs/project-setup.md)).

## When to Use

- Any session where UI/UX decisions need to be made before or during coding
- When the user wants to see the live app, discuss layout, or compare before/after states
- When a design decision is unresolved and a wireframe would help
- When iterating on an existing surface
- When building from Figma designs with Code Connect

## Prerequisites — Check Before Starting

At session start, verify the required tools are available. **agent-browser is preferred** — use Playwright MCP only when you need specific features it provides.

**Quick check via npm (if ux-collab is installed as a package):**
```bash
npm run check    # Verifies agent-browser, ImageMagick, MCP configs
```

**Manual checks:**
```
1. agent-browser (PRIMARY)
   → Check: agent-browser --version
   → Install if missing:
      brew install agent-browser          # macOS (fastest)
      npm install -g agent-browser          # any platform
   → First run: agent-browser install      # Downloads Chrome for Testing

2. ImageMagick (screenshot optimization)
   → Check: which convert && which identify
   → Install:
      brew install imagemagick             # macOS
      sudo apt install imagemagick         # Ubuntu/Debian

3. Playwright MCP (ALTERNATIVE — use when needed)
   → Try: mcp_playwright_browser_navigate { url: "about:blank" }
   → When to use Playwright instead of agent-browser:
      * Need full accessibility tree with semantic roles
      * Complex multi-page interactions with state
      * Specific viewport/device emulation beyond agent-browser devices
      * MCP ecosystem already configured and working
   → Fallback: if MCP unavailable, agent-browser handles all core needs

4. Figma MCP (OPTIONAL — for design system alignment)
   → For pulling tokens, verifying components, Code Connect integration
   → Requires Figma Pro + API key
   → Use when: design system is in Figma with Code Connect

5. Lucid MCP (OPTIONAL — for wireframes)
   → For ideation, simple wireframes, explanations
   → Falls back to Markdown wireframes when unavailable
   → See "Lucid vs Figma" section for when to use each

6. Dev server
   → Navigate to target URL; if unreachable, check Session Startup Checklist
```

---

## Browser Tool Selection Guide

| Use **agent-browser** when | Use **Playwright MCP** when |
|---|---|
| Quick visual review | Need full accessibility tree with semantic roles |
| Token efficiency matters (~200-400 tokens vs 3000-5000) | Complex multi-page interactions with state |
| Headless, local development | Specific geolocation/permissions |
| CI/CD or terminal-only environments | Rich semantic element analysis |
| Screenshot + basic interaction needed | Viewport resizing via dynamic MCP tools |

**Default workflow**: Start with agent-browser. Switch to Playwright MCP if you hit limitations.

## Related Skills

For browser automation, install the official **agent-browser** skill which teaches agents the full API:

```bash
npx skills add vercel-labs/agent-browser --skill agent-browser
```

This skill provides:
- Complete command reference (navigate, snapshot, interact, screenshot)
- Session and authentication workflows
- Diffing and evaluation capabilities
- Best practices for browser automation

**When to use:** Combine with ux-collab when you need deep browser automation beyond basic screenshots — form filling, multi-step workflows, session persistence, or testing.

See all agent-browser skills: https://agent-browser.dev/skills


| Use **agent-browser** when | Use **Playwright MCP** when |
|---|---|
| Quick visual review | Need full accessibility tree with semantic roles |
| Token efficiency matters (~200-400 tokens vs 3000-5000) | Complex multi-page interactions with state |
| Headless, local development | Specific geolocation/permissions |
| CI/CD or terminal-only environments | Rich semantic element analysis |
| Screenshot + basic interaction needed | Viewport resizing via dynamic MCP tools |

**Default workflow**: Start with agent-browser. Switch to Playwright MCP if you hit limitations.

---

## Design Tool Selection: Lucid vs Figma

**Key insight from [Code Connect article](https://uxdesign.cc/designing-with-claude-code-and-codex-cli-building-ai-driven-workflows-powered-by-code-connect-ui-f10c136ec11f):**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| **Lucid** | Ideation, simple wireframes, explanations | Early concept exploration, layout discussions, stakeholder communication, rough "what if" scenarios |
| **Figma** | Fine-tuning, design systems, component tracking | Component specification, token verification, design-code alignment, production-grade specs, Code Connect integration |

**Decision tree:**
- Is this a new rough idea where layout is uncertain? → **Lucid**
- Are we specifying component behavior, tokens, or states? → **Figma**
- Building from an existing design system? → **Figma MCP** (pull tokens/components)
- Need to verify implementation matches design? → **Figma MCP** (compare screenshot)

---

## The Loop

```
SEE → DISCUSS → IDEATE → SPECIFY → BUILD → VERIFY → SYNC → RECORD
        ↑___________↓___________________________↓
           (Lucid)          (Figma + Code Connect)
```

1. **SEE** — Screenshot live app with agent-browser or Playwright MCP
2. **DISCUSS** — Identify design questions and constraints
3. **IDEATE** — Rough wireframes in Lucid (or Markdown) for layout exploration
4. **SPECIFY** — Figma MCP + Code Connect for component/token specification
5. **BUILD** — Implement with real components and tokens
6. **VERIFY** — agent-browser + Figma MCP comparison for token compliance
7. **SYNC** — Update Figma with implementation notes (optional, future)
8. **RECORD** — Document decisions in design decisions file

---

## Step 1 — SEE (Browser Snapshot)

Open the live app and establish shared visual context.

**Primary approach (agent-browser):**
```bash
agent-browser open <target-url>     # Navigate
agent-browser snapshot -i             # Get accessibility tree with refs
agent-browser screenshot page.png     # Full page screenshot
./optimize-screenshot.sh              # Optimize for chat (<80KB)
```

**Alternative (Playwright MCP) when richer features needed:**
```
Actions:
- mcp_playwright_browser_navigate → target URL
- mcp_playwright_browser_take_screenshot { type: "png" }
- ./optimize-screenshot.sh
- mcp_playwright_browser_snapshot (full accessibility tree)
- mcp_playwright_browser_resize for responsive checks:
    mobile:  390×844
    tablet:  768×1024
    desktop: 1440×900
```

**Screenshot optimization is mandatory** before attaching any screenshot to chat. Raw screenshots can exceed 280KB. The optimize script resizes to max 1280px wide and converts to JPEG at 82% quality — output reliably lands under 80KB.

```bash
# Optimize latest screenshot automatically:
./optimize-screenshot.sh

# Or optimize a specific file:
./optimize-screenshot.sh /path/to/screenshot.png
```

After capturing, state your observations in **3–5 bullet points**:
- Overall layout and visual hierarchy
- Empty states or placeholder content
- Interaction affordances (buttons, inputs, links)
- Spacing and alignment issues
- Anything that looks broken or unfinished

---

## Step 2 — DISCUSS

Synthesize observations into design questions. Ask **exactly one focused question** at a time.

**Types of design questions (pick the right frame):**

| Question type | When to use | Example |
|---|---|---|
| **Layout** | Structure or grid is unclear | "Should this stack vertically on mobile or stay side-by-side?" |
| **Hierarchy** | Content priority is ambiguous | "Is the headline or the CTA the primary element here?" |
| **Pattern** | Multiple valid UI patterns exist | "Would a stepped form or all-at-once scroll work better for this survey?" |
| **State** | Empty/error/loading states are missing | "What should appear when there are no results yet?" |
| **Interaction** | Click/hover/focus behavior is undefined | "Should filtering update results live or require a submit?" |

Check the project decisions doc (from `.ux-collab.md` → `decisionsDoc`) before asking — don't re-litigate resolved decisions.

---

## Step 3 — IDEATE (Lucid or Markdown Wireframes)

**Purpose:** Rough layout exploration, early concept communication

**Use Lucid when:**
- Exploring multiple layout options
- Communicating rough ideas to stakeholders
- Creating quick "what if" scenarios
- Layout structure is still uncertain

**Use Markdown when:**
- Lucid MCP is unavailable
- Quick textual representation suffices
- Developer handoff is immediate

### With Lucid MCP:

```
Actions:
- mcp_lucid_lucid_create_diagram_from_specification → generate wireframe
- mcp_lucid_lucid_create_document_share_link → share
- mcp_lucid_lucid_export_image → pull image back into conversation
- agent-browser open <lucidShareUrl> → preview
```

**Wireframe conventions:**
- Label sections (Header, Hero, Sidebar, Main Content)
- Show grid/structure but not pixel-perfect spacing
- Mark content types (H1, Button, Card Grid)
- Indicate responsive breakpoints if layout changes
- Mark open decisions with `[?]`

**When NOT to use Lucid:**
- Component specification (use Figma)
- Token verification (use Figma)
- Final design approval (use Figma)

### Markdown Fallback:

```markdown
## Wireframe: [Surface Name] — [Viewport]

Layout: [describe grid, e.g., "2-col, 16px gap, max-w-4xl centered"]

┌─────────────────────────────────────┐
│  [HEADER]  Logo        Nav links    │
├─────────────────────────────────────┤
│  [HERO]                             │
│  H1: Primary headline               │
│  Body: Supporting copy              │
│  [CTA Button — brand-gold]          │
├─────────────┬───────────────────────┤
│  [SIDEBAR]  │  [MAIN CONTENT]       │
│  Filter A   │  Card grid (3-col)    │
│  Filter B   │  ...                  │
└─────────────┴───────────────────────┘

States needed: empty, loading, error, filled
Open decisions: [?] sidebar collapse behavior on mobile
```

---

## Step 4 — SPECIFY (Figma MCP + Code Connect)

**Purpose:** Component specification, token verification, design-code alignment

**Prerequisites:**
- Figma Pro account
- Figma MCP Server configured
- Code Connect set up in Figma (components linked to GitHub)

### When to Use Figma MCP:

1. **Before BUILD:** Pull tokens and component specs
   ```
   - mcp_figma_get_variable_defs   → Extract design tokens
   - mcp_figma_get_design_context  → Code Connect snippet + variants + screenshot
   - Verify all tokens exist in local CSS
   ```

2. **During BUILD:** Reference component specs
   ```
   - mcp_figma_get_screenshot      → See exact design
   - mcp_figma_get_variable_defs   → Verify token names match
   ```

3. **After BUILD:** Verify implementation
   ```
   - mcp_figma_get_screenshot      → Capture design
   - Compare to agent-browser screenshot
   - Verify tokens match implementation
   ```

### Component State Matrix (Document in .ux-collab.md):

Document expected component states for verification:

```markdown
| Element | Property | Default | Hover | Active | Focus | Disabled |
|---------|----------|---------|-------|--------|-------|----------|
| Button (Primary) | Background | --bg-primary | --bg-primary-hover | --bg-primary-active | --bg-primary | --bg-disabled |
| Button (Primary) | Border | none | none | none | --border-focus | none |
| Button (Primary) | Text Color | --text-on-primary | --text-on-primary | --text-on-primary | --text-on-primary | --text-disabled |
```

### MCP Instructions per Component:

Reference these from Code Connect UI to guide AI behavior:

- "Always use 'primary' variant for main CTAs, 'secondary' for supporting actions"
- "Text should be sentence case (not uppercase)"
- "Icons should use --icon-size-md (20px) for default size"
- "Disabled state uses reduced opacity (0.5), not grey background"
- "Transitions should use --ease-standard (--duration-fast: 150ms)"

---

## Step 5 — BUILD

Implement only what was agreed in Steps 2–4. No scope creep.

**Project-specific target files are in `.ux-collab.md`** — read it before touching any files.

If no `.ux-collab.md` exists, discover targets by:
```bash
# Find the component and style entrypoints
find . -name "globals.css" -not -path "*/node_modules/*" | head -5
find . -name "tailwind.config*" -not -path "*/node_modules/*" | head -3
ls app/ components/ src/ 2>/dev/null | head -20
```

### Universal Code Rules:
- **All colors via design tokens only** — no inline hex values
- **Use project's existing component system** — check `.ux-collab.md` `preferences.components.library`
- **Respect tech stack preferences** from `.ux-collab.md`:
  - Framework: React/Vue/Svelte as specified
  - Styling: Tailwind v4 vs v3, CSS modules, etc.
  - Primitives: base-ui, Radix, Headless UI as specified
  - Additional registries: @react-bits, @magicui, etc.
- **No new dependencies** without explicit discussion (except from approved registries)
- **Accessibility semantics:** correct heading levels, button vs. link, ARIA labels on interactive elements
- **Match Figma tokens** via mcp_figma_get_variable_defs when available

### Design System Check (if Figma MCP available):
```
Before coding:
[ ] Read .ux-collab.md preferences section
[ ] mcp_figma_search_design_system → Find matching component
[ ] mcp_figma_get_design_context   → Code Connect snippet + variants
[ ] Check component matches preferred primitives (base-ui vs Radix, from preferences)
[ ] Verify component exists in local codebase OR installable from approved registries
[ ] Check token names match local CSS

If component uses wrong primitive library:
→ Search additional registries listed in preferences
→ Consider building from scratch with preferred primitives
→ Document why in decisions file

If component missing or tokens mismatch:
→ Flag for design system update
→ Document in decisions file
```

### Tech Stack Preferences (from .ux-collab.md):

**Check preferences at start of BUILD:**
```
preferences:
  framework: react              # Build React components, not Vue
  components:
    library: shadcn            # Use shadcn/ui patterns
    primitives: base-ui        # NOT Radix — use base-ui equivalents
  styling:
    solution: tailwindcss
    version: "4"               # Use Tailwind v4 patterns
  quality:
    strictTypes: true           # Full TypeScript with strict mode
```

**Implementation guidance based on preferences:**

| Preference | Implementation Rule |
|------------|---------------------|
| `components.library: shadcn` | Use `npx shadcn add`, not `npm install` |
| `components.primitives: base-ui` | Import from `@base-ui-components/react`, not `@radix-ui` |
| `components.registry: [@react-bits]` | Can install from these registries without asking |
| `styling.version: "4"` | Use Tailwind v4 `@import` syntax, not v3 directives |
| `language: typescript` | Full TypeScript types, no `any` |
| `framework: react` | Use Server Components where appropriate |

**Component installation priority:**
1. Does component already exist in local codebase? → Use existing
2. Is it in shadcn built-in registry? → `npx shadcn add [component]`
3. Is it in approved additional registries? → Install from that registry
4. Neither? → Build from preferred primitives (base-ui, not Radix)

---

## Step 6 — VERIFY (Browser + Figma Comparison)

After every code change, reload and verify implementation matches intent.

**Screenshot comparison:**
```bash
agent-browser open <target-url>
agent-browser screenshot implementation.png
mcp_figma_get_screenshot → design.png
# Compare side-by-side
```

**Token compliance check:**
```
1. mcp_figma_get_variable_defs → Extract expected tokens
2. Check computed styles in browser:
   - agent-browser open <url>
   - agent-browser click @element-ref
   - agent-browser evaluate → getComputedStyle(element)
3. Verify CSS properties match token values
4. Document any discrepancies
```

**Visual diff callouts:**
- ✅ What matches design intent
- ⚠️ What's off but acceptable
- ❌ What needs fixing before RECORD

**Responsive verification:**
```bash
agent-browser --device "iPhone 12" open <url>
agent-browser screenshot mobile.png

agent-browser --device "iPad" open <url>
agent-browser screenshot tablet.png
```

---

## Step 7 — SYNC (Code-to-Figma)

Sync implementation to Figma for design documentation.

### When to Use:
- Code-first development workflow
- Keeping Figma in sync with shipped code  
- Generating design system from implementation

### Workflow:

```bash
# 1. Scan component
code-to-figma scan src/components/Button.tsx

# 2. Generate plugin bundle
code-to-figma plugin-output -i .figma -o plugin-data.json

# 3. Import in Figma:
# Plugins → Code to Figma → Import from JSON
```

### Configuration

Add to `.ux-collab.md`:

```yaml
codeToFigma:
  enabled: true
  outputDir: ".figma"
  onBuild: true      # Sync after successful build
```

See: [code-to-figma skill](../code-to-figma/SKILL.md) for full documentation.

---

## Step 8 — RECORD

Update the project decisions doc (path in `.ux-collab.md` → `decisionsDoc`, default: `docs/DESIGN_DECISIONS.md`).

**Structure:**
```markdown
## Open Decisions
- [?] Mobile sidebar behavior still TBD

## Decided
**[Decision name]** — [chosen option].
Rationale: [one sentence why].
Implementation notes: [link to PR or file]
Figma reference: [link to Figma frame]
Date: [YYYY-MM].

## Design Principles
- Always use semantic tokens, never primitives directly in components
- Button text is always sentence case
```

**If Figma MCP was used during session:**
- Link to Figma frames used
- Note any token mismatches discovered
- Document Code Connect status for new components

---

## Minimal Mode — Quick Visual Review

For lightweight sessions (no wireframe, no Figma, quick check):

```bash
agent-browser open <target-url>
agent-browser screenshot page.png
./optimize-screenshot.sh
# State 3–5 observations, ask one focused question
```

---

## Session Startup Checklist

```
[ ] agent-browser installed and working?
    → Check: agent-browser --version
    → Install: brew install agent-browser OR npm i -g agent-browser
    → First run: agent-browser install

[ ] Playwright MCP available (backup/alternative)?
    → Try: mcp_playwright_browser_navigate to "about:blank"
    → If agent-browser fails, use Playwright MCP

[ ] Figma MCP configured (optional)?
    → Check: .mcp.json for figma server
    → Verify FIGMA_API_KEY is set
    → Only needed for design token workflows

[ ] Dev server running?
    → Check: agent-browser open <target-url>
    → Start: run the project's dev task

[ ] Read .ux-collab.md (if present)
    → Sets: defaultUrl, decisionsDoc, brandTokens, targetFiles, surfaces, figmaFileUrl

[ ] Check if this is "IDEATE" or "SPECIFY" phase
    → Rough layout? IDEATE (Lucid)
    → Component specs? SPECIFY (Figma)

[ ] Take baseline screenshot
    → agent-browser open <url> + agent-browser screenshot + ./optimize-screenshot.sh

[ ] Confirm scope: which surface, which phase, which tools needed
```

---

## Quick Reference

### agent-browser (Primary)

```bash
# Installation
brew install agent-browser           # macOS
npm install -g agent-browser         # any platform
agent-browser install                # Download Chrome (first-time)

# Core workflow
Navigate:    agent-browser open <url>
Screenshot:  agent-browser screenshot [path.png] [--full]
Optimize:    ./optimize-screenshot.sh
Snapshot:    agent-browser snapshot -i  (accessibility tree with refs)
Click:       agent-browser click @<ref>  (from snapshot)
Scroll:      agent-browser scroll <up/down/left/right> [px]
Evaluate:    agent-browser eval "document.querySelector('...').style"
Close:       agent-browser close

# Responsive testing
Devices:     agent-browser --device "iPhone 12" open <url>
             agent-browser --device "iPad" open <url>
             agent-browser --device "Pixel 5" open <url>

# Configuration file
Config:      agent-browser.json (project root)
```

### Playwright MCP (Alternative)

```
Navigate:    mcp_playwright_browser_navigate { url }
Screenshot:  mcp_playwright_browser_take_screenshot { type: "png" }
Snapshot:    mcp_playwright_browser_snapshot  (full a11y tree)
Click:       mcp_playwright_browser_click { ref }
Resize:      mcp_playwright_browser_resize { width, height }
Evaluate:    mcp_playwright_browser_evaluate { script }
Scroll:      mcp_playwright_browser_mouse_wheel { deltaY }
```

### Figma MCP (Design System)

```
# Token & Component Access
Get variables:      mcp_figma_get_variable_defs   { fileKey }
Search components:  mcp_figma_search_design_system { fileKey, query }
Get design context: mcp_figma_get_design_context  { fileKey, nodeId }  ← primary
Get screenshot:     mcp_figma_get_screenshot      { fileKey, nodeId }

# Code Connect
Get map:            mcp_figma_get_code_connect_map          { fileKey }
Suggest mappings:   mcp_figma_get_code_connect_suggestions  { fileKey }
```

### Lucid (Wireframes)

```
Create:      mcp_lucid_lucid_create_diagram_from_specification { title, description, ... }
Share:       mcp_lucid_lucid_create_document_share_link { documentId, email }
Export:      mcp_lucid_lucid_export_image { documentId }
Preview:     agent-browser open <lucidShareUrl>
```

---

## Updated .ux-collab.md Format

```yaml
# UX Collab — Project Config

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# REQUIRED SETTINGS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

defaultUrl: http://localhost:3000
decisionsDoc: docs/DESIGN_DECISIONS.md

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TECH STACK PREFERENCES (NEW)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

preferences:
  # Framework
  framework: react                    # react, vue, svelte, solid
  language: typescript                # typescript, javascript
  
  # Styling
  styling:
    solution: tailwindcss             # tailwindcss, css-modules, styled-components
    version: "4"                      # 3 or 4 for Tailwind
    config: app/globals.css           # Path to main CSS/tailwind config
  
  # Component System
  components:
    library: shadcn                   # shadcn, ark-ui, mantine, etc.
    primitives: base-ui               # base-ui, radix, headlessui (for shadcn)
    registry:                           # Additional shadcn-compatible registries
      - @react-bits
      - @magicui
      - @aceternity
    aliases:                          # Import aliases
      components: "@/components"
      utils: "@/lib/utils"
  
  # Code Quality
  quality:
    strictTypes: true
    lintCommand: "npm run lint"
    formatCommand: "npm run format"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIGMA INTEGRATION (OPTIONAL)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

figmaFileUrl: https://www.figma.com/design/ABC123/your-file
codeConnectEnabled: true

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TARGET FILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

targetFiles:
  tokens: app/globals.css
  components: app/_components/
  layouts: app/layouts/

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DESIGN TOKENS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

brandTokens:
  colors:
    primary: --color-primary
    secondary: --color-secondary
  spacing:
    sm: --space-4
    md: --space-8
    lg: --space-16

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SURFACE MAP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

surfaces:
  - name: Homepage
    route: /
    components: [Hero, FeatureGrid, Footer]
  - name: Dashboard
    route: /dashboard
    components: [Sidebar, DataTable, Card]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPEN DECISIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

openDecisions:
  - Navigation pattern — sidebar vs. top nav
  - Mobile layout — stacked vs. tabs
```

---

## See Also

- [Figma Integration Guide](figma-integration.md) — Detailed Figma MCP workflow
- [Project Setup](docs/project-setup.md) — Full `.ux-collab.md` format
- Original article: [Designing with Claude Code and Code Connect](https://uxdesign.cc/designing-with-claude-code-and-codex-cli-building-ai-driven-workflows-powered-by-code-connect-ui-f10c136ec11f)
