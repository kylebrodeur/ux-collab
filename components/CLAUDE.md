# CLAUDE.md — Components Directory

## Purpose

This directory contains all React components. Each component must follow the design system rules, use semantic tokens, and document its states.

## Component Requirements

### 0. Tech Stack Preferences (ALWAYS CHECK FIRST)

Before implementing any component, read `.ux-collab.md` `preferences` section:

```yaml
# Example preferences from .ux-collab.md
preferences:
  framework: react
  components:
    library: shadcn
    primitives: base-ui        # NOT Radix
    registry:
      - @react-bits
      - @magicui
    aliases:
      components: "@/components"
      utils: "@/lib/utils"
  styling:
    solution: tailwindcss
    version: "4"              # Not v3
  quality:
    strictTypes: true
```

**MUST follow when building:**
- ✅ Use specified framework (React, Vue, etc.)
- ✅ Use specified primitive library (base-ui vs Radix)
- ✅ Use Tailwind v4 syntax if specified (not v3)
- ✅ Can install from approved registries without asking
- ✅ Use specified import aliases
- ❌ NEVER use different primitives than specified
- ❌ NEVER use Tailwind v3 syntax with v4 preference

**Installing components:**
```bash
# 1. Check if exists in local codebase first
ls src/components/ | grep -i button

# 2. If shadcn preference: use shadcn CLI
npx shadcn add button

# 3. If additional registries: install from there
# (e.g., @react-bits, @magicui)

# 4. If custom: build from preferred primitives
# base-ui example: npm install @base-ui-components/react
```

```tsx
// ✅ Correct: Uses semantic tokens
<button className="button button--primary">
  Click me
</button>

// ❌ Wrong: Hardcoded styles
<button style={{ background: '#3b82f6', color: 'white' }}>
  Click me
</button>
```

### 2. State Documentation

Every component must have a state matrix in comments or separate file:

```tsx
/**
 * Button Component State Matrix
 * 
 * | Element | Property | Default | Hover | Active | Focus | Disabled |
 * |---------|----------|---------|-------|--------|-------|----------|
 * | Container | Background | --bg-primary | --bg-primary-hover | --bg-primary-active | --bg-primary | --bg-disabled |
 * | Container | Border | none | none | none | --border-focus | none |
 * | Text | Color | --text-on-primary | --text-on-primary | --text-on-primary | --text-on-primary | --text-disabled |
 * 
 * Implementation Rules:
 * - Uses CSS custom properties, never hardcoded values
 * - Transitions: --ease-standard (--duration-fast: 150ms)
 */
export function Button({ variant = 'primary', children, ...props }: ButtonProps) {
  // Implementation
}
```

### 3. Accessibility Requirements

```tsx
// ✅ Correct heading hierarchy
<section>
  <h2>Section Title</h2>  {/* Use correct level, not always h1 */}
  <h3>Subsection</h3>
</section>

// ✅ Proper button vs link usage
<button onClick={handleClick}>Action</button>
<a href="/page">Navigation</a>

// ✅ ARIA labels for icons
<button aria-label="Close dialog">
  <XIcon />
</button>

// ✅ Form labels
<label htmlFor="email">Email</label>
<input id="email" type="email" />
```

## Component Implementation Workflow

### When Building from Figma:

```
1. mcp_figma_search_design_system → Find component in Figma
2. mcp_figma_get_design_context   → Variants, Code Connect snippet, screenshot
3. Verify tokens exist in styles/semantic.css
4. Create component following Figma specs
5. Run design-verification agent
6. Run component-compliance-checker agent
```

### Token Usage Pattern

```tsx
// components/Button/Button.tsx
import './Button.css';

export interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  children: React.ReactNode;
  onClick?: () => void;
}

export function Button({ 
  variant = 'primary', 
  size = 'md', 
  disabled = false,
  children,
  onClick 
}: ButtonProps) {
  const className = [
    'button',
    `button--${variant}`,
    `button--${size}`,
    disabled && 'button--disabled'
  ].filter(Boolean).join(' ');

  return (
    <button 
      className={className}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

```css
/* components/Button/Button.css */
.button {
  /* Uses semantic tokens from styles/semantic.css */
  font-family: var(--font-sans);
  font-weight: var(--font-weight-medium);
  border: none;
  cursor: pointer;
  transition: all var(--duration-fast) var(--ease-standard);
}

/* Sizes */
.button--sm {
  padding: var(--space-8) var(--space-12);
  font-size: var(--text-sm);
  border-radius: var(--radius-sm);
}

.button--md {
  padding: var(--space-12) var(--space-16);
  font-size: var(--text-base);
  border-radius: var(--radius-md);
}

.button--lg {
  padding: var(--space-16) var(--space-24);
  font-size: var(--text-lg);
  border-radius: var(--radius-lg);
}

/* Variants */
.button--primary {
  background: var(--bg-primary);
  color: var(--text-on-primary);
}

.button--primary:hover:not(:disabled) {
  background: var(--bg-primary-hover);
}

.button--primary:active:not(:disabled) {
  background: var(--bg-primary-active);
}

.button--primary:focus-visible {
  outline: var(--focus-ring-width) solid var(--focus-ring-color);
  outline-offset: var(--focus-ring-offset);
}

.button--secondary {
  background: var(--bg-secondary);
  color: var(--text-primary);
}

/* Disabled state */
.button--disabled,
.button:disabled {
  background: var(--bg-disabled);
  color: var(--text-disabled);
  cursor: not-allowed;
  opacity: 0.6;
}
```

## Component Verification

### Before Committing:

```
[ ] Component uses only semantic tokens (no hardcoded values)
[ ] State matrix documented (via comments or separate file)
[ ] Accessibility: correct heading levels, labels, ARIA where needed
[ ] All props have TypeScript types
[ ] Responsive behavior tested (mobile/tablet/desktop)
[ ] design-verification agent completed
[ ] component-compliance-checker agent passed
```

## Composition Patterns

### Container + Child Components

```tsx
// Card composition
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
    <CardDescription>Description</CardDescription>
  </CardHeader>
  <CardContent>
    {/* Content */}
  </CardContent>
  <CardFooter>
    <Button>Action</Button>
  </CardFooter>
</Card>
```

### Slot Pattern

```tsx
// Flexible content areas
<Modal>
  <ModalHeader title="Confirm" />
  <ModalBody>
    {/* Custom content */}
    <p>Are you sure?</p>
  </ModalBody>
  <ModalFooter>
    <Button variant="secondary">Cancel</Button>
    <Button variant="danger">Delete</Button>
  </ModalFooter>
</Modal>
```

## Common Mistakes to Avoid

```tsx
// ❌ Inline styles
<div style={{ margin: '16px', color: '#333' }}>

// ❌ Direct primitive token usage in component
<div style={{ margin: 'var(--space-16)' }}>

// ❌ Wrong heading levels (always h1)
<section>
  <h1>Subsection</h1>  {/* Should be h2 or lower */}
</section>

// ❌ Button used for navigation
<button onClick={() => router.push('/page')}>Go</button>

// ❌ Missing ARIA for icon-only buttons
<button>🗑️</button>

// ✅ Correct patterns:
<div className="card"> {/* Uses --space-component */}
<section>
  <h2>Subsection</h2>
</section>
<a href="/page">Go</a>
<button aria-label="Delete item">🗑️</button>
```

## Figma MCP Workflow

When Figma MCP is available, use this workflow:

### Before Building:

```
1. mcp_figma_search_design_system { query: "Button" }
2. If found:
   - mcp_figma_get_design_context → Variants + Code Connect snippet + screenshot
   - mcp_figma_get_variable_defs  → Verify token names
3. Implement following Figma spec exactly
4. Document in component comments: "Figma ref: [filename]#[node-id]"
```

### After Building:

```
1. agent-browser open <component-url>
2. agent-browser screenshot component.png
3. mcp_figma_get_screenshot → design.png
4. Compare side-by-side
5. If mismatched: iterate or document divergence in DESIGN_DECISIONS.md
```

## Agent Invocation Guide

### During Development

```
User: "Build a new Card component"
→ Phase: BUILD
→ Steps:
   1. Check if Card exists in Figma: mcp_figma_search_design_system
   2. If yes: pull specs, tokens, code snippet
   3. Implement component
   4. Run design-verification agent
   5. Run component-compliance-checker agent
   6. VERIFY phase: screenshot + compare
   7. RECORD phase: update DESIGN_DECISIONS.md
```

```
User: "Is this Button using the right tokens?"
→ Phase: VERIFY
→ Steps:
   1. Run token-analyzer agent
   2. Check for hardcoded values
   3. Verify against Figma (if available)
   4. Report findings
```

## Resources

- [styles/CLAUDE.md](../styles/CLAUDE.md) — Token validation rules
- [../CLAUDE.md](../CLAUDE.md) — Root governance
- [ux-collab Skill](../../skills/ux-collab/SKILL.md) — Full workflow
- [Figma Integration](../../skills/ux-collab/figma-integration.md) — Figma MCP usage
