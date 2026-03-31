---
name: ux-collab
description: "Visual-first UI/UX collaboration loop using Playwright (live app) and Lucid (wireframes). Use when designing or iterating on UI, reviewing the live app visually, creating wireframes, making layout decisions, discussing design before building, or running a design→build→verify loop. Trigger phrases: 'let's work on the UI', 'show me what it looks like', 'create a wireframe', 'design the layout', 'take a screenshot', 'browser view', 'before we build let's decide'."
compatibility: "Requires: Playwright MCP (mcp_playwright_*), ImageMagick (convert + identify CLI). Optional: Lucid MCP (mcp_lucid_*) — falls back to Markdown wireframes when unavailable."
license: MIT
metadata:
  author: kylebrodeur
  version: "2.0"
---

# UX Collaboration Skill

A structured loop for visual-first UI/UX design and implementation. Works with any web app running locally — project-specific routes, surfaces, and brand tokens are configured per-project via `.ux-collab.md` (see [Project Setup](docs/project-setup.md)).

## When to Use

- Any session where UI/UX decisions need to be made before or during coding
- When the user wants to see the live app, discuss layout, or compare before/after states
- When a design decision is unresolved and a wireframe would help
- When iterating on an existing surface

## Prerequisites — Check Before Starting

At session start, verify the required tools are available:

```
1. Playwright MCP   → try mcp_playwright_browser_navigate { url: "about:blank" }
                      If it fails: ask user to start Playwright MCP server
2. ImageMagick      → run: which convert && which identify
                      If missing: brew install imagemagick  (macOS)
                                  sudo apt install imagemagick  (Ubuntu/Debian)
3. Lucid MCP        → optional; if unavailable, use Markdown wireframe fallback (Step 3b)
4. Dev server       → navigate to target URL; if unreachable, check Session Startup Checklist
```

If Playwright MCP is unavailable, **stop and ask the user to resolve it** — this skill cannot proceed without it.

---

## The Loop

```
SEE → DISCUSS → DESIGN → BUILD → VERIFY → RECORD
```

### Step 1 — SEE (Playwright)

Open the live app and establish shared visual context.

```
Actions:
- mcp_playwright_browser_navigate → target URL (check .ux-collab.md for default)
- mcp_playwright_browser_take_screenshot { type: "png" }
- ./optimize-screenshot.sh        → prints optimized path, logs size reduction
- mcp_playwright_browser_snapshot (accessibility tree for element refs + a11y audit)
- mcp_playwright_browser_resize for responsive checks:
    mobile:  390×844
    tablet:  768×1024
    desktop: 1440×900
```

**Screenshot optimization is mandatory** before attaching any screenshot to chat. Raw Playwright PNGs can exceed 280KB. The optimize script resizes to max 1280px wide and converts to JPEG at 82% quality — output reliably lands under 80KB.

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

### Step 2 — DISCUSS

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

### Step 3a — DESIGN (Lucid) — When Lucid MCP is available

When structural or layout decisions need visual communication, produce a Lucid wireframe.

```
Actions:
- mcp_lucid_lucid_create_diagram_from_specification → generate wireframe
- mcp_lucid_lucid_create_document_share_link → share (get email from .ux-collab.md or ask)
- mcp_lucid_lucid_export_image → pull image back into conversation
- mcp_playwright_browser_navigate → open diagram URL for review
```

**Wireframe conventions:**
- Label everything: component name, content type, interaction state (empty/filled/error/disabled)
- Show the dominant layout grid (column count, gaps, max-width)
- Include mobile and desktop artboards when layout changes significantly across breakpoints
- Use brand token names in labels (e.g., `bg-brand-navy`, `text-brand-gold`) — check `.ux-collab.md` for project tokens
- Mark unresolved decisions as `[?]` in the diagram

**When to wireframe vs. just describe:**
- **Wireframe**: new surface, layout restructure, before/after comparison, multiple competing options
- **Describe**: minor spacing/color tweaks, copy changes, single-component fixes

### Step 3b — DESIGN (Markdown Fallback) — When Lucid MCP is unavailable

Produce a structured Markdown wireframe directly in chat:

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

Label open decisions with `[?]`. Get explicit agreement before moving to BUILD.

### Step 4 — BUILD

Implement only what was agreed in Steps 2–3. No scope creep.

**Project-specific target files are in `.ux-collab.md`** — read it before touching any files.

If no `.ux-collab.md` exists, discover targets by:
```bash
# Find the component and style entrypoints
find . -name "globals.css" -not -path "*/node_modules/*" | head -5
find . -name "tailwind.config*" -not -path "*/node_modules/*" | head -3
ls app/ components/ src/ 2>/dev/null | head -20
```

**Universal code rules:**
- All colors via design tokens only — no inline hex values
- Use the project's existing component system (shadcn/ui, Radix, MUI, etc.) — extend, don't replace
- No new dependencies without explicit discussion
- Keep accessibility semantics: correct heading levels, button vs. link, ARIA labels on interactive elements

### Step 5 — VERIFY (Playwright)

After every code change, reload and compare.

```
Actions:
- mcp_playwright_browser_navigate → reload route
- mcp_playwright_browser_take_screenshot → capture after state
- ./optimize-screenshot.sh → optimize before attaching
- mcp_playwright_browser_scroll_down / click through key interactions
- mcp_playwright_browser_evaluate → inspect computed styles if needed
```

**Visual diff**: Side-by-side compare before/after. Call out:
- ✅ What changed and matches intent
- ⚠️ What's still off
- ❌ What regressed

**Accessibility audit** — run after every significant change:
```
- mcp_playwright_browser_snapshot → review the accessibility tree
  Check: heading hierarchy (h1→h2→h3), button labels, form labels,
         ARIA roles on custom components, focus order
- mcp_playwright_browser_evaluate → getComputedStyle checks for color contrast
```

**Responsive check matrix:**
```
Mobile  390×844  → mcp_playwright_browser_resize { width: 390, height: 844 }
Tablet  768×1024 → mcp_playwright_browser_resize { width: 768, height: 1024 }
Desktop 1440×900 → mcp_playwright_browser_resize { width: 1440, height: 900 }
```
Take a screenshot at each breakpoint when layout changes significantly.

### Step 6 — RECORD

Update the project decisions doc (path in `.ux-collab.md` → `decisionsDoc`, default: `docs/DESIGN_DECISIONS.md`).

Move resolved decisions from "Open" to "Decided":

```markdown
**[Decision name]** — [chosen option].
Rationale: [one sentence why].
Date: [YYYY-MM].
```

If no decisions doc exists yet, create one with sections:
- `## Open Decisions`
- `## Decided`
- `## Design Principles` (for persistent rules that came out of discussion)

---

## Minimal Mode — Quick Visual Review

For lightweight sessions (no wireframe, no build) — just SEE + DISCUSS:

```
1. mcp_playwright_browser_navigate → target URL
2. mcp_playwright_browser_take_screenshot
3. ./optimize-screenshot.sh
4. State 3–5 observations
5. Ask one focused question
```

Use this when:
- User wants a fast gut-check before a full session
- Verifying a single deployed fix
- Getting visual context before planning work

---

## Session Startup Checklist

```
[ ] Dev server running?
    → Check: mcp_playwright_browser_navigate to target URL
    → Start: run the project's dev task / npm run dev / pnpm dev

[ ] Read .ux-collab.md (if it exists in the project root)
    → Sets: defaultUrl, decisionsDoc, brandTokens, targetFiles, surfaces

[ ] Take baseline screenshot of target surface
    → mcp_playwright_browser_take_screenshot + ./optimize-screenshot.sh

[ ] Check decisions doc for any choices made last session
    → path from .ux-collab.md, default: docs/DESIGN_DECISIONS.md

[ ] Confirm scope: which surface and which decision is in scope today
```

---

## Quick Reference

### Playwright

```
Navigate:    mcp_playwright_browser_navigate { url }
Screenshot:  mcp_playwright_browser_take_screenshot { type: "png" }
Optimize:    ./optimize-screenshot.sh
             → /tmp/playwright-screenshots-optimized/*-opt.jpg (<80KB)
Snapshot:    mcp_playwright_browser_snapshot  (a11y tree + element refs)
Click:       mcp_playwright_browser_click { ref }
Resize:      mcp_playwright_browser_resize { width, height }
Evaluate:    mcp_playwright_browser_evaluate { script }
Scroll:      mcp_playwright_browser_mouse_wheel { deltaY }
```

### Lucid

```
Create:      mcp_lucid_lucid_create_diagram_from_specification { title, description, ... }
Share:       mcp_lucid_lucid_create_document_share_link { documentId, email }
Export:      mcp_lucid_lucid_export_image { documentId }
Preview:     mcp_playwright_browser_navigate { url: lucidShareUrl }
```

---

## Project Configuration

This skill is project-agnostic. Project-specific settings (target URL, brand tokens, file paths, surfaces, open decisions) live in a `.ux-collab.md` file at your project root.

See [docs/project-setup.md](docs/project-setup.md) for the full `.ux-collab.md` format and examples.

**At session start: always check for `.ux-collab.md` and read it if present.**
