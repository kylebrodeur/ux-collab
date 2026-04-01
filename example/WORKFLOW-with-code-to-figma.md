# Full Workflow Example: Dashboard with Code-to-Figma Sync

This demonstrates the complete ux-collab workflow including the SYNC phase with code-to-figma.

---

## Prerequisites

```bash
# 1. Install ux-collab
npx ux-collab setup

# 2. Install code-to-figma
bash scripts/setup-code-to-figma.sh

# 3. Configure .code-to-figma.json with Figma credentials
```

---

## Scenario

You're building a new Dashboard component. The workflow is:
1. Build in code first (code-first development)
2. Sync to Figma for design team review
3. Iterate based on feedback

---

## Step 1-5: Standard ux-collab Loop

**User:** "Let's work on the dashboard"

**Agent:** 
- [SEE] Screenshot current state
- [DISCUSS] "What's missing from the dashboard?"
- [IDEATE] Wireframe in Lucid (optional)
- [SPECIFY] Pull Button component from Figma if needed
- [BUILD] Create Dashboard.tsx with all components

**Dashboard.tsx created:**
```tsx
export function Dashboard() {
  return (
    <div className="p-8 max-w-6xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
      <StatsGrid />
      <DataTable />
    </div>
  );
}
```

---

## Step 6: VERIFY

**Agent:**
```bash
agent-browser open http://localhost:3000/dashboard
agent-browser screenshot dashboard.png
./optimize-screenshot.sh
```

**Verification results:**
✅ Layout matches wireframe  
✅ Components render correctly  
⚠️ StatsGrid needs more padding

---

## Step 7: SYNC (NEW!)

**User:** "Sync this dashboard component to Figma"

**Agent actions:**

```bash
# 1. Scan the Dashboard component
code-to-figma scan src/components/Dashboard.tsx -o .figma

# Output:
# ✓ Dashboard → .figma/Dashboard.figma.json
#   Variants: 1
#   Props detected: 0
```

```bash
# 2. Also scan child components
code-to-figma scan src/components/StatsGrid.tsx -o .figma
code-to-figma scan src/components/DataTable.tsx -o .figma
```

```bash
# 3. Generate plugin bundle
code-to-figma plugin-output -i .figma -o plugin-data.json

# Output:
# ✓ Generated plugin-data.json with 3 components
```

**Agent response:**
```
Synced to Figma:
• Dashboard (1 variant)
• StatsGrid (3 variants: default, compact, expanded)
• DataTable (2 variants: default, loading)

Plugin bundle ready: plugin-data.json

Import in Figma Desktop:
  Plugins → Development → code-to-figma
  → Load file → plugin-data.json
  → Select all → Build selected
  → Frames appear on page: code-to-figma
```

---

## Step 8: RECORD

**Agent updates DESIGN_DECISIONS.md:**

```markdown
## Dashboard Component

**Decision:** Built with StatsGrid + DataTable composition
**Rationale:** Modular design allows reuse in other surfaces
**Implementation:** `app/dashboard/Dashboard.tsx`
**Figma Reference:** [Dashboard component in Design System](https://figma.com/design/...)
**Code-to-Figma Sync:** plugin-data.json generated 2026-03-31
**Variants:**
  - StatsGrid: default, compact, expanded
  - DataTable: default, loading
```

---

## Full Integration Pattern

### Pattern A: Full Workflow with SYNC

```
User: "Build a pricing page and sync to Figma"

Agent:
  [SEE] Screenshot current site
  [DISCUSS] "What pricing tiers?"
  User: "Free, Pro, Enterprise"
  [IDEATE] Wireframe 3-tier layout
  [SPECIFY] Pull Card component from Figma
  [BUILD] PricingPage.tsx with PricingCard
  [VERIFY] Screenshot matches spec
  [SYNC] code-to-figma scan PricingCard.tsx
         → Generated plugin-data.json
         → Ready for Figma import
  [RECORD] Update decisions doc
```

### Pattern B: Quick Component Sync

```
User: "Just sync the new Badge component to Figma"

Agent (skips full loop):
  [SYNC] code-to-figma scan Badge.tsx
         → Badge.figma.json
         → Plugin ready
         Done!
```

### Pattern C: Batch Sync

```
User: "Sync all updated components to Figma"

Agent:
  [SYNC] code-to-figma scan src/components/**/*.tsx
         → Scanning 15 files
         → Generated 12 components (3 skipped - no changes)
         → Bundle: plugin-data.json
         → Ready for import
```

---

## Configuration for This Project

`.ux-collab.md`:

```yaml
defaultUrl: http://localhost:3000
decisionsDoc: docs/DESIGN_DECISIONS.md

# Tech Stack Preferences
preferences:
  framework: react
  components:
    library: shadcn
    primitives: base-ui
    registries:
      - @react-bits
  styling:
    solution: tailwindcss
    version: "4"

# Code-to-Figma Integration
codeToFigma:
  enabled: true
  cliCommand: "npx code-to-figma"
  outputDir: ".figma"
  autoSync: false
  onBuild: true       # Ask after BUILD
  onVerify: false     # Don't auto-sync

figmaFileKey: "ABC123"
```

---

## Handling Conflicts

**Scenario:** Component already exists in Figma

```
Agent: "StatsGrid already exists in Figma. Options:"
       "[overwrite] Replace Figma version with code"
       "[skip] Keep Figma version, skip sync"
       "[compare] Show diff before deciding"

User: "compare"

Agent: [Shows side-by-side]
       Code: padding-24 (96px)
       Figma: padding-32 (128px)
       
User: "overwrite" (designs should match code)
```

---

## Continuous Sync with Watch Mode

```bash
# During active development
code-to-figma scan "src/components/**/*.tsx" --watch

# Automatically regenerates .figma.json on save
# Designer refreshes plugin to see updates
```

---

## Summary

| Phase | Tool | Output |
|-------|------|--------|
| SEE | agent-browser | screenshot.png |
| DISCUSS | — | design decisions |
| IDEATE | Lucid | wireframe |
| SPECIFY | Figma MCP | component specs |
| BUILD | — | Component.tsx |
| VERIFY | agent-browser | verified.png |
| **SYNC** | **code-to-figma** | **.figma.json** |
| RECORD | — | DESIGN_DECISIONS.md |

The SYNC phase bridges code and design, enabling code-first workflows while keeping design documentation in sync.
