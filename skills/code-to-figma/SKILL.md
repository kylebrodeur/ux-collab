---
name: code-to-figma
description: "Sync React components to Figma designs. Use when: 'sync component to Figma', 'generate Figma from code', 'create design system in Figma', 'export React to Figma'. Parses React/TSX with Babel AST, resolves Tailwind classes, outputs Figma-compatible JSON for loading via Figma Desktop plugin."
compatibility: "Requires: Node.js 18+, @kylebrodeur/code-to-figma CLI (npm i -g or npx). Optional: Figma Desktop with local plugin loaded from packages/plugin/manifest.json."
license: MIT
metadata:
  author: kylebrodeur
  version: "0.2.0"
  upstream: https://github.com/kylebrodeur/code-to-figma
---

# Code-to-Figma Skill

> **This skill is maintained upstream in [kylebrodeur/code-to-figma](https://github.com/kylebrodeur/code-to-figma).**
> Install the authoritative version with:
> ```bash
> npx skills add kylebrodeur/code-to-figma
> ```
> The upstream skill contains the complete command reference, supported patterns, troubleshooting, and plugin setup. After install it loads automatically alongside ux-collab.

---

## Quick Reference

### Workflow

```
1. code-to-figma scan src/components/Button.tsx
   → .figma/Button.figma.json

2. code-to-figma plugin-output -i .figma -o plugin-data.json
   → plugin-data.json  (all components bundled)

3. Figma Desktop → Plugins → Development → Import plugin from manifest…
   → select packages/plugin/manifest.json from the code-to-figma repo

4. Plugin UI → Load file → plugin-data.json → check components → Build selected
   → Frames appear on page "code-to-figma"
```

### Commands

| Command | Purpose |
|---------|---------|
| `init` | Create `.code-to-figma.json` config |
| `scan <pattern>` | Parse component(s) → `.figma.json` per file |
| `scan --watch` | Re-scan on save |
| `scan -t <path>` | Custom Tailwind config path |
| `scan --validate` | Validate generated JSON |
| `plugin-output` | Bundle `.figma.json` files → `plugin-data.json` |
| `read --file-key <key>` | Read components from Figma REST API (read-only) |

### Config (`.code-to-figma.json`)

```json
{
  "figmaFileKey": "YOUR_FILE_KEY",
  "figmaAccessToken": "YOUR_ACCESS_TOKEN",
  "componentGlob": "src/components/**/*.tsx",
  "tokenMapping": {
    "--color-primary": "primary/500",
    "--color-secondary": "secondary/500"
  },
  "outputDir": ".figma",
  "framework": "react",
  "styling": "tailwind",
  "parserOptions": {
    "extractVariantsFromProps": true,
    "detectClassNameUtilities": true,
    "extractSpacing": true
  }
}
```

### Integration with ux-collab

Add to `.ux-collab.md`:

```yaml
codeToFigma:
  enabled: true
  cliCommand: "npx @kylebrodeur/code-to-figma"
  onBuild: true
```

During the **SYNC** phase: scan built components → `plugin-output` → import in Figma Desktop.

### Figma Desktop Plugin Setup (one-time)

The plugin ships as source in the code-to-figma repo — it is **not** on the Figma Community marketplace.

1. Clone or download [kylebrodeur/code-to-figma](https://github.com/kylebrodeur/code-to-figma)
2. Open **Figma Desktop** (plugin API unavailable in browser)
3. **Plugins → Development → Import plugin from manifest…**
4. Select `packages/plugin/manifest.json` from the repo
5. Plugin appears under **Plugins → Development → code-to-figma**

### Figma MCP (optional — design system read)

To read tokens/components from Figma files during the SPECIFY/VERIFY phases, configure the Figma MCP:

```json
// .mcp.json
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

Requires Figma Pro. See [figma-integration.md](../ux-collab/figma-integration.md) for available tools.

