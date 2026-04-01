# Figma MCP Integration for ux-collab

## Overview
Figma MCP (Model Context Protocol) enables AI agents to:
- Read design tokens and variables directly from Figma files
- Access component specifications via Code Connect
- Verify implementations against design specifications
- Pull screenshots for visual comparison

## When to Use Figma MCP vs Lucid

| Need | Tool | Reason |
|------|------|--------|
| Quick layout exploration | **Lucid** | Faster, less structured, for ideation |
| Component specification | **Figma** | Source of truth for tokens, variants, states |
| Design-code alignment check | **Figma** | Code Connect links design to implementation |
| Token verification | **Figma** | CSS variables mapped to Figma variables |
| Wireframe for stakeholders | **Lucid** | Easier sharing, no Figma account needed |
| Component library audit | **Figma** | Comprehensive component inventory |

## Prerequisites

1. **Figma Pro account** (required for Dev Mode and Code Connect)
2. **Figma MCP Server** configured:
   ```json
   // .mcp.json
   {
     "mcpServers": {
       "figma": {
         "command": "npx",
         "args": ["-y", "@figma/mcp"],
         "env": {
           "FIGMA_API_KEY": "your-api-key"
         }
       }
     }
   }
   ```
3. **Code Connect configured** in Figma:
   - Link design components to GitHub source
   - Map variants to props
   - Add MCP instructions for AI guidance

## Available MCP Tools

### Get Design Context
```
mcp_figma_get_design_context  → Primary tool: returns code, screenshot, Code Connect hints for a node
mcp_figma_get_metadata        → File metadata and page structure
mcp_figma_get_screenshot      → Capture design node as image
mcp_figma_get_variable_defs   → Extract variable/token values (colors, spacing, typography)
mcp_figma_search_design_system → Search for components by name/pattern
```

### Code Connect
```
mcp_figma_get_code_connect_map          → Get existing Code Connect mappings
mcp_figma_get_code_connect_suggestions  → Suggest component mappings from codebase
mcp_figma_add_code_connect_map          → Add/update a Code Connect mapping
```

### Design System
```
mcp_figma_create_design_system_rules    → Create/update design system rules for AI guidance
mcp_figma_search_design_system          → Search components, styles, and variables
```

## Workflow: Design-to-Code with Figma MCP

### Step 1: Extract Design Tokens
Before building, pull tokens from Figma to ensure alignment:

```
1. mcp_figma_get_variable_defs → Extract all primitive tokens
2. mcp_figma_get_variable_defs → Extract semantic tokens
3. Read local CSS files → Compare token names
4. If mismatch: warn and use Figma as source of truth
```

### Step 2: Component Selection
When implementing a new feature:

```
1. mcp_figma_search_design_system → Find matching components
2. mcp_figma_get_design_context  → Get variant props, Code Connect snippet, screenshot
3. Verify component exists in local codebase
4. If component missing: flag for design system update
```

### Step 3: Implementation Verification
After building:

```
1. agent-browser screenshot → Capture implementation
2. mcp_figma_get_screenshot  → Capture design at same viewport
3. Compare: token usage, spacing, typography
4. mcp_figma_get_variable_defs → Verify tokens used correctly
```

## Code Connect MCP Instructions

Add MCP instructions to components in Figma for AI guidance:

### Example: Button Component
```
MCP Instructions:
- Always use "primary" variant for main CTAs, "secondary" for supporting actions
- Text should always be sentence case (not uppercase)
- Icons should use --icon-size-md (20px) for default size
- Disabled state uses reduced opacity (0.5), not grey background
- For destructive actions, use "danger" variant with confirmation dialog
```

### Example: Card Component
```
MCP Instructions:
- Padding should always use --space-scale-md (16px) on all sides
- Shadow uses --shadow-card token, never custom box-shadow values
- Header text should be truncated to 1 line with ellipsis
- Description supports max 3 lines before truncation
- Hover state lifts card with --translate-y-sm (2px up)
```

## Component State Matrix Pattern

Document component states in Figma using a matrix:

```markdown
## Button Component State Matrix

| Element | Property | Default | Hover | Active | Focus | Disabled |
|---------|----------|---------|-------|--------|-------|----------|
| Container | Background | --bg-primary | --bg-primary-hover | --bg-primary-active | --bg-primary | --bg-disabled |
| Container | Border | none | none | none | --border-focus | none |
| Text | Color | --text-on-primary | --text-on-primary | --text-on-primary | --text-on-primary | --text-disabled |

### Implementation Rules:
- Use CSS custom properties, never hardcoded values
- Transitions should use --ease-standard (--duration-fast: 150ms)
- Focus ring uses --focus-ring-width (2px) and --focus-ring-color
```

## Token Architecture Pattern

### Primitive Tokens (Figma Foundation)
- Colors: grey-50, grey-100, grey-200... grey-900
- Typography: font-sans, font-mono
- Spacing: space-4, space-8, space-12...
- Radii: radius-sm, radius-md, radius-lg
- Shadows: shadow-sm, shadow-md, shadow-lg

### Semantic Tokens (Code Implementation)
- Colors: --bg-primary, --bg-secondary, --bg-danger
- --text-primary, --text-secondary, --text-muted
- Spacing: --space-section, --space-component, --space-element
- --ease-standard, --ease-enter, --ease-exit

### Component Tokens (High-level)
- --button-bg-primary-default
- --card-shadow-default
- --input-border-radius

## Quality Gates

Block implementation if:
- [ ] Tokens match Figma variables
- [ ] Component exists in Code Connect
- [ ] All states documented in matrix
- [ ] MCP instructions reviewed

## Future: Code-to-Design Sync

When Figma releases code-to-design features (mentioned in article):
1. Implement in code first
2. AI detects components in implementation
3. Push component instances back to Figma
4. Auto-generate design specs from code
5. Maintain bidirectional sync

## Resources

- [Figma MCP Documentation](https://github.com/figma/mcp)
- [Code Connect UI Documentation](https://help.figma.com/hc/en-us/articles/23265235058215-Code-Connect)
- Article reference: [Designing with MCP Server](https://medium.com/design-bootcamp/designing-with-mcp-server-bridging-design-systems-and-ai-for-developer-friendly-prototypes-4f08b0a0881d)
