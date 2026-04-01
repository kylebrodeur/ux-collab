# Full Workflow Example: Dashboard Design

This example demonstrates the complete 8-step ux-collab workflow using agent-browser (primary), Figma MCP (for design system), and Lucid (for ideation).

---

## Prerequisites

```bash
# Verify setup
npx ux-collab check

# Ensure .ux-collab.md exists with Figma URL
```

---

## Step 1: SEE — Screenshot Current State

**Agent command:**
```
User: "Let's work on the dashboard UI. Take a screenshot."
```

**Agent actions:**
```bash
agent-browser open http://localhost:3000/dashboard
agent-browser screenshot current-state.png
./optimize-screenshot.sh
```

**Agent response:**
```
Observations:
• Empty state with placeholder text
• No clear visual hierarchy
• Missing CTA for adding items
• Sidebar navigation incomplete
```

---

## Step 2: DISCUSS — Identify Design Questions

**Agent asks:**
```
"What should appear in the empty state? A welcome message with a CTA, 
or a getting-started guide with steps?"
```

**User responds:**
```
"Getting-started guide with 3 steps."
```

---

## Step 3: IDEATE — Lucid Wireframe

**Agent command:**
```
User: "Create a wireframe for the getting-started guide."
```

**Agent actions (Lucid MCP):**
```
mcp_lucid_lucid_create_diagram_from_specification {
  title: "Dashboard Empty State",
  description: "3-step getting started guide with CTA"
}
```

**OR Markdown fallback:**
```markdown
## Wireframe: Dashboard Empty State

┌─────────────────────────────────────┐
│  [SIDEBAR]                          │
│  • Dashboard (active)               │
│  • Settings                         │
│                                     │
├─────────────────────────────────────┤
│  [MAIN]                             │
│  H1: Welcome to Dashboard           │
│  Body: Get started in 3 steps:      │
│                                     │
│  [Step 1] Connect data source    →  │
│  [Step 2] Configure settings     →  │
│  [Step 3] Invite team members    →  │
│                                     │
│  [CTA: Complete Setup — Primary]    │
└─────────────────────────────────────┘

States: default, loading (during setup), complete
Open decisions: [?] Should steps be clickable or just status indicators?
```

---

## Step 4: SPECIFY — Figma MCP + Code Connect

**Agent command:**
```
User: "Pull the Step Indicator component from Figma and use it for the guide."
```

**Agent actions (Figma MCP):**
```
1. mcp_figma_search_design_system { query: "Step Indicator" }
   → Found: "StepIndicator" (id: 123:456)

2. mcp_figma_get_design_context { fileKey, nodeId: "123:456" }
   → Variants: default, completed, active
   → Props: stepNumber, title, description, status
   → Code Connect snippet:
     <StepIndicator
       stepNumber={1}
       title="Connect data source"
       status="pending"
     />

3. mcp_figma_get_variable_defs { fileKey }
   → Uses: --step-indicator-gap, --step-indicator-size
   → Colors: --step-indicator-active-bg, --step-indicator-completed-bg

4. Verify tokens exist in local CSS:
   grep --step-indicator src/styles/tokens.css
   → Present ✓
```

**Agent response:**
```
Found StepIndicator component in Figma:
• 3 variants: default, completed, active
• Uses tokens: --step-indicator-*
• Code Connect provides React component
• All tokens verified in local CSS
```

---

## Step 5: BUILD — Implementation

**Agent commands:**
```
User: "Build the empty state using StepIndicator for the 3 steps."
```

**Agent creates:**
```tsx
// app/dashboard/EmptyState.tsx
import { StepIndicator } from '@/components/StepIndicator';
import { Button } from '@/components/Button';

export function EmptyState() {
  const steps = [
    { number: 1, title: 'Connect data source', status: 'pending' },
    { number: 2, title: 'Configure settings', status: 'locked' },
    { number: 3, title: 'Invite team members', status: 'locked' },
  ];

  return (
    <div className="empty-state">
      <h1>Welcome to Dashboard</h1>
      <p>Get started in 3 steps:</p>
      
      <div className="steps-list">
        {steps.map(step => (
          <StepIndicator
            key={step.number}
            stepNumber={step.number}
            title={step.title}
            status={step.status}
          />
        ))}
      </div>
      
      <Button variant="primary">Complete Setup</Button>
    </div>
  );
}
```

```css
/* app/dashboard/EmptyState.css */
.empty-state {
  padding: var(--space-section);
  max-width: var(--content-max-width);
  margin: 0 auto;
}

.empty-state h1 {
  font-size: var(--text-heading);
  color: var(--text-primary);
  margin-bottom: var(--space-element);
}

.steps-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-component);
  margin: var(--space-component) 0;
}
```

---

## Step 6: VERIFY — Screenshot + Token Check

**Agent command:**
```
User: "Verify the implementation matches the Figma design."
```

**Agent actions:**
```bash
# 1. Screenshot implementation
agent-browser open http://localhost:3000/dashboard
agent-browser screenshot implementation.png
./optimize-screenshot.sh

# 2. Capture Figma design
mcp_figma_get_screenshot { 
  fileKey: "ABC123",
  nodeId: "789:012"
}

# 3. Compare side-by-side
# Agent analyzes: spacing, colors, typography alignment

# 4. Token compliance check
grep -r "step-indicator" src/components/StepIndicator/
→ All using --step-indicator-* tokens ✓
```

**Agent reports:**
```
Verification Results:
✅ StepIndicator component rendered correctly
✅ Spacing matches Figma spec (16px gaps)
✅ Colors use correct tokens (--step-indicator-active-bg)
⚠️ Button width: implementation 200px vs Figma 180px (acceptable)
→ Overall: Pass
```

**Responsive check:**
```bash
agent-browser --device "iPhone 12" open http://localhost:3000/dashboard
agent-browser screenshot mobile.png
```

---

## Step 7: SYNC — Update Documentation

**Agent command:**
```
User: "Record this implementation in the design decisions."
```

**Agent updates:**
```markdown
<!-- docs/DESIGN_DECISIONS.md -->

## Decided

**Dashboard Empty State** — Getting started guide with 3 steps.
Rationale: Clarifies onboarding flow, reduces user drop-off.
Implementation: `app/dashboard/EmptyState.tsx`
Figma Reference: [StepIndicator component](https://figma.com/design/ABC123?node-id=123:456)
Tokens Used: --step-indicator-*, --space-section, --text-heading
Date: 2026-03-31
```

---

## Step 8: RECORD — Compliance Check

**Agent runs:**
```
component-compliance-checker agent:
  ✓ CLAUDE.md workflow followed
  ✓ Tokens verified against Figma
  ✓ Component uses semantic tokens only
  ✓ Accessibility: proper heading hierarchy
  ✓ DESIGN_DECISIONS.md updated
  ✓ Figma reference linked
```

---

## Full Session Summary

**User prompts used:**
1. "Let's work on the dashboard UI"
2. "Create a wireframe for the getting-started guide"
3. "Pull the Step Indicator component from Figma"
4. "Build the empty state using StepIndicator"
5. "Verify the implementation matches the Figma design"
6. "Record this implementation"

**Tools used:**
- agent-browser (screenshots, verification)
- Lucid MCP (wireframe) / Markdown fallback
- Figma MCP (components, tokens, Code Connect)

**Time:** ~15-20 minutes for complete flow

---

## Variations

### Without Figma MCP:
- Skip Step 4 (SPECIFY)
- Use local component library instead
- Verify against visual review only

### With Playwright MCP only:
- Use `mcp_playwright_browser_navigate` instead of agent-browser
- More detailed accessibility tree
- Same workflow otherwise

### Quick mode (SEE + DISCUSS only):
```
User: "Show me the current dashboard"
→ Screenshot + 3-5 observations
→ One focused question
→ Done (no BUILD)
```
