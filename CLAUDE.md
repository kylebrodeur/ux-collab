# CLAUDE.md — UX Collab Project Governance

## Project Overview

This project uses the **ux-collab** workflow for visual-first UI/UX design and implementation. The workflow follows an 8-step loop:

```
SEE → DISCUSS → IDEATE → SPECIFY → BUILD → VERIFY → SYNC → RECORD
        ↑___________↓___________________________↓
           (Lucid)          (Figma + Code Connect)
```

## Tool Stack

| Purpose | Primary Tool | Alternative |
|---------|---------------|-------------|
| Browser automation | **agent-browser** | Playwright MCP |
| Design system/specs | **Figma MCP** | — |
| Wireframes/ideation | **Lucid MCP** | Markdown fallback |
| Screenshot optimization | **ImageMagick** | — |

## Quality Gates

Every task must pass these gates before being considered complete:

### Cannot Proceed If:

- [ ] **Design verification** finds token mismatches (when Figma MCP available)
- [ ] **Tech stack compliance** violated (wrong primitives, wrong Tailwind version, etc.)
- [ ] **Build fails** (compilation errors)
- [ ] **Lint fails** (code style violations)
- [ ] **CLAUDE.md compliance checker** finds workflow violations

### Tech Stack Compliance (NEW)

Before BUILD phase, verify preferences from `.ux-collab.md`:

```
Required checks:
[ ] Component uses specified primitive library (base-ui, Radix, etc.)
[ ] Tailwind version matches preference (v3 vs v4)
[ ] Framework matches (React, Vue, Svelte, etc.)
[ ] TypeScript strictness matches preference
[ ] Component is from approved registry OR built from preferred primitives
```

**Preferred primitives mapping:**
- `base-ui` → import from `@base-ui-components/react`
- `radix-ui` → import from `@radix-ui/react-*`
- `headlessui` → import from `@headlessui/react`

**Tailwind v4 vs v3 compatibility:**
- v4: Uses `@import "tailwindcss"` and CSS-first config
- v3: Uses `@tailwind` directives and JS config
- **NEVER mix v3 and v4 patterns in same project**

### Token Compliance Rules

1. **Always use semantic tokens**, never hardcoded hex values
2. **Verify tokens exist in Figma** before using (via `mcp_figma_get_variables`)
3. **CSS custom properties only** — no inline styles for colors/spacing
4. **Match Figma variable names** to CSS custom property names

## Available Subagents

When working on complex tasks, invoke these specialized agents:

### 1. design-verification
**Use when:** Verifying component implementations match Figma specs

**Invocation:**
```
Invoke design-verification agent to verify that [ComponentName] 
matches Figma specifications for tokens, spacing, and states.
```

**Returns:**
- Token compliance report
- Visual diff analysis
- State coverage check
- Recommended fixes

### 2. token-analyzer
**Use when:** Analyzing token usage patterns and optimization

**Invocation:**
```
Invoke token-analyzer agent to check [component-directory] for 
hardcoded values and token usage patterns.
```

**Returns:**
- Hardcoded values found
- Primitive vs semantic token usage
- Optimization recommendations

### 3. component-compliance-checker  
**Use when:** Final validation before RECORD phase (MANDATORY)

**Invocation:**
```
Invoke component-compliance-checker agent for final validation.
```

**Returns:**
- Workflow adherence check
- Token compliance
- Accessibility validation
- Documentation status
- BLOCK/PROCEED decision
## Workflow Steps

### Phase Detection

At session start, determine which phase we're in:

| User Request | Phase | Tool |
|--------------|-------|------|
| "let's wireframe this" | IDEATE | Lucid |
| "what component should I use?" | SPECIFY | Figma MCP |
| "build the dashboard" | BUILD + VERIFY | agent-browser |
| "does this match the design?" | VERIFY | agent-browser + Figma MCP |

### Decision Tree

1. **Is this a new rough idea where layout is uncertain?**
   → YES: Use Lucid (IDEATE phase)
   → NO: Continue to #2

2. **Are we specifying component behavior, tokens, or states?**
   → YES: Use Figma MCP (SPECIFY phase)
   → NO: Continue to #3

3. **Building from existing design system?**
   → YES: Use Figma MCP to pull tokens/components
   → NO: Proceed with BUILD using local tokens

## File Structure

```
project-root/
├── CLAUDE.md                    # This file — root governance
├── .ux-collab.md               # Per-project config (url, tokens, surfaces)
├── agent-browser.json          # Browser config (optional)
├── .mcp.json                   # MCP servers config (Figma, etc.)
├── styles/
│   ├── CLAUDE.md              # Token validation rules
│   ├── primitives.css         # Primitive tokens (colors, spacing)
│   └── semantic.css           # Semantic tokens (bg-primary, text-heading)
├── components/
│   ├── CLAUDE.md              # Component-specific rules
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.css
│   │   └── Button.stories.tsx
│   └── Card/
│       └── ...
└── docs/
    └── DESIGN_DECISIONS.md     # Decision log
```

## Token Architecture

### Primitive Tokens (Foundation)
```css
/* styles/primitives.css */
:root {
  /* Colors */
  --color-grey-50: #f9fafb;
  --color-grey-100: #f3f4f6;
  --color-grey-200: #e5e7eb;
  /* ... */
  
  /* Spacing */
  --space-4: 0.25rem;
  --space-8: 0.5rem;
  --space-12: 0.75rem;
  /* ... */
}
```

### Semantic Tokens (Intent)
```css
/* styles/semantic.css */
:root {
  /* Backgrounds */
  --bg-primary: var(--color-blue-600);
  --bg-secondary: var(--color-grey-100);
  --bg-disabled: var(--color-grey-200);
  
  /* Text */
  --text-primary: var(--color-grey-900);
  --text-secondary: var(--color-grey-600);
  --text-on-primary: var(--color-white);
  
  /* Spacing */
  --space-section: var(--space-32);
  --space-component: var(--space-16);
  --space-element: var(--space-8);
}
```

### Component Tokens (Implementation)
```css
/* components/Button/Button.css */
.button {
  background: var(--bg-primary);
  color: var(--text-on-primary);
  padding: var(--space-12) var(--space-16);
  border-radius: var(--radius-md);
}
```

## Component State Matrix Template

Every component must document its states:

```markdown
## [Component Name] State Matrix

| Element | Property | Default | Hover | Active | Focus | Disabled |
|---------|----------|---------|-------|--------|-------|----------|
| Container | Background | --bg-primary | --bg-primary-hover | --bg-primary-active | --bg-primary | --bg-disabled |
| Container | Border | none | none | none | --border-focus | none |
| Text | Color | --text-on-primary | --text-on-primary | --text-on-primary | --text-on-primary | --text-disabled |
| Icon | Transform | none | none | scale(0.95) | none | none |

### Implementation Rules:
- Use CSS custom properties, never hardcoded values
- Transitions: --ease-standard (--duration-fast: 150ms)
- Focus ring: --focus-ring-width (2px) + --focus-ring-color
```

## Naming Conventions

### Files
- Components: PascalCase (`Button.tsx`, `CardGrid.tsx`)
- Styles: kebab-case (`button.css`, `card-grid.css`)
- Utils: camelCase (`useTheme.ts`, `formatDate.ts`)

### CSS Classes
- BEM methodology: `.button`, `.button--primary`, `.button__icon`
- Utility classes: `.u-sr-only`, `.u-text-center`

### Design Tokens
- Primitive: `--{category}-{scale}` (`--color-grey-100`, `--space-8`)
- Semantic: `--{property}-{variant}` (`--bg-primary`, `--text-secondary`)
- Component: `--{component}-{property}-{variant}` (`--button-bg-primary`)

## MCP Instructions

When working with Figma components, add these instructions to guide AI:

### Button Component
```
MCP Instructions:
- Always use "primary" variant for main CTAs, "secondary" for supporting actions
- Text should always be sentence case (not uppercase)
- Icons should use --icon-size-md (20px) for default size
- Disabled state uses reduced opacity (0.5), not grey background
- For destructive actions, use "danger" variant with confirmation dialog
```

### Card Component
```
MCP Instructions:
- Padding should always use --space-component (16px) on all sides
- Shadow uses --shadow-card token, never custom box-shadow values
- Header text should be truncated to 1 line with ellipsis
- Description supports max 3 lines before truncation
- Hover state lifts card with --translate-y-sm (2px up)
```

## Session Protocol

### Startup Checklist
```
[ ] Read CLAUDE.md (this file)
[ ] Read .ux-collab.md (project config)
[ ] CHECK preferences section in .ux-collab.md:
    - Framework: React/Vue/Svelte → use correct patterns
    - Primitives: base-ui/Radix/Headless → use correct imports
    - Tailwind: v3 vs v4 → use correct syntax
    - Approved registries → can install without asking
[ ] Check agent-browser: agent-browser --version
[ ] Check Figma MCP: verify .mcp.json has figma server
[ ] Determine phase: IDEATE, SPECIFY, BUILD, or VERIFY
[ ] Confirm scope: which surface, which decision
```

### Before BUILD
```
[ ] Read .ux-collab.md preferences again
[ ] Pull tokens from Figma (if available): mcp_figma_get_variables
[ ] Verify component exists: mcp_figma_search_components
[ ] Get Code Connect snippet: mcp_figma_get_code
[ ] Check component matches preferred primitives (base-ui vs Radix)
[ ] Confirm all tokens exist in local CSS
```

### After BUILD (Before VERIFY)
```
[ ] Invoke design-verification agent
[ ] Run token-analyzer agent
[ ] Screenshot implementation: agent-browser screenshot
[ ] Compare to Figma: mcp_figma_get_screenshot (if available)
[ ] Verify tech stack compliance: primitives, Tailwind version, etc.
```

### Before RECORD
```
[ ] MUST: Run component-compliance-checker agent
[ ] Update DESIGN_DECISIONS.md
[ ] Link to Figma frames used (if applicable)
[ ] Document any tech stack exceptions (if had to deviate from preferences)

## Resources

- [ux-collab Skill Documentation](./skills/ux-collab/SKILL.md)
- [Figma Integration Guide](./skills/ux-collab/figma-integration.md)
- Original article: [Designing with Claude Code and Code Connect](https://uxdesign.cc/designing-with-claude-code-and-codex-cli-building-ai-driven-workflows-powered-by-code-connect-ui-f10c136ec11f)
