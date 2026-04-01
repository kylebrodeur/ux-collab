# CLAUDE.md — Styles Directory

## Purpose

This directory contains all design tokens and global styles. Token validation and enforcement happens here.

## Token Architecture

We use a three-tier token system:

1. **Primitive Tokens** — Raw values (colors, spacing, typography)
2. **Semantic Tokens** — Intent-based (backgrounds, text, borders)
3. **Component Tokens** — High-level component-specific values

## File Organization

```
styles/
├── primitives.css      # Color scales, spacing scales, raw values
├── semantic.css        # Intent-based tokens (bg-primary, text-heading)
├── components.css      # Component-specific token mappings
├── globals.css         # Global styles, resets, base typography
└── CLAUDE.md          # This file
```

## Token Validation Rules

### ✅ Allowed Patterns

```css
/* Primitive to Semantic mapping */
--bg-primary: var(--color-blue-600);
--text-secondary: var(--color-grey-600);

/* Semantic to Component mapping */
.button {
  background: var(--bg-primary);
  color: var(--text-on-primary);
}
```

### ❌ Forbidden Patterns

```css
/* Hardcoded values */
.button {
  background: #3b82f6;        /* ❌ Never do this */
  color: rgb(255, 255, 255);   /* ❌ Never do this */
}

/* Direct primitive usage in components */
.card {
  padding: var(--space-16);   /* ❌ Use var(--space-component) */
}
```

## Adding New Tokens

### Step 1: Add to primitives.css
```css
/* styles/primitives.css */
:root {
  --color-purple-50: #faf5ff;
  --color-purple-100: #f3e8ff;
  /* etc. */
}
```

### Step 2: Map to semantic.css
```css
/* styles/semantic.css */
:root {
  --bg-accent: var(--color-purple-500);
  --text-accent: var(--color-purple-700);
}
```

### Step 3: Verify with Figma (if available)
```
1. mcp_figma_get_variable_defs → Check if token exists in Figma
2. Verify name matches Figma variable
3. If mismatch: document in DESIGN_DECISIONS.md
```

## Token Compliance Check

When implementing new components, verify:

```
[ ] No hardcoded hex/RGB values
[ ] No direct primitive usage (--space-16 vs --space-component)
[ ] All colors use semantic tokens
[ ] All spacing uses semantic tokens
[ ] Typography uses semantic tokens (--text-heading vs --font-size-24)
```

## Figma Token Sync

If using Figma MCP, always verify tokens before using:

```
1. mcp_figma_get_variable_defs { fileKey }
2. Check token name matches local CSS custom property
3. Example: Figma "bg/primary" → CSS "--bg-primary"
```

## Common Token Mappings

| Figma Variable | CSS Custom Property | Usage |
|----------------|---------------------|-------|
| `bg/primary` | `--bg-primary` | Primary button backgrounds |
| `bg/secondary` | `--bg-secondary` | Secondary surfaces |
| `text/primary` | `--text-primary` | Main body text |
| `text/on-primary` | `--text-on-primary` | Text on primary backgrounds |
| `space/16` | `--space-component` | Component internal spacing |
| `radius/md` | `--radius-md` | Default border radius |

## Responsive Token Guidelines

### Spacing Scales
- Use semantic tokens that scale with viewport if needed
- Mobile: `--space-section` may reduce on smaller screens
- Never use fixed pixel values for component spacing

### Typography
- Use semantic size tokens (`--text-heading` vs `--text-body`)
- Let components handle responsive sizing, not tokens

## Debugging Token Issues

If tokens aren't applying:

1. Check if CSS file is imported in component
2. Verify token exists: `getComputedStyle(element).getPropertyValue('--token-name')`
3. Check for CSS specificity conflicts
4. Verify no hardcoded values overriding tokens

## Agent Instructions

When working in this directory:

1. **Always verify token exists** before referencing it
2. **Never create new tokens** without checking if semantic equivalent exists
3. **Prefer semantic over primitive** in component usage
4. **Document token additions** in DESIGN_DECISIONS.md
