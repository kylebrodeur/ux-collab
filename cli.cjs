#!/usr/bin/env node
/**
 * ux-collab CLI
 * Check and set up dependencies for the ux-collab agent skill.
 *
 * Usage:
 *   npx ux-collab check     → verify all deps are installed
 *   npx ux-collab setup     → install missing deps + create .ux-collab.md
 *   npx ux-collab init      → create .ux-collab.md config in current project
 *   npx ux-collab help      → show this help
 */

'use strict';

const { spawn } = require('child_process');
const { resolve, join } = require('path');
const { existsSync, writeFileSync } = require('fs');

const PKG_ROOT = resolve(__dirname);
const SCRIPTS_DIR = join(PKG_ROOT, 'scripts');

function runScript(scriptName, extraArgs = []) {
  const scriptPath = join(SCRIPTS_DIR, scriptName);
  if (!existsSync(scriptPath)) {
    console.error(`Error: script not found: ${scriptPath}`);
    process.exit(1);
  }
  const child = spawn('/bin/bash', [scriptPath, ...extraArgs], { stdio: 'inherit' });
  child.on('close', (code) => process.exit(code ?? 0));
}

function showHelp() {
  console.log(`
ux-collab — Visual-first UI/UX collaboration skill

Usage: npx ux-collab <command>

Commands:
  check    Verify all dependencies are installed and ready
  setup    Install missing dependencies and create .ux-collab.md
  init     Create a starter .ux-collab.md in the current directory
  help     Show this help

Examples:
  npx ux-collab check          # Quick readiness check
  npx ux-collab setup          # Full setup (installs ImageMagick, guides MCP)
  npx ux-collab init           # Just create the project config

After setup, trigger the skill in your agent:
  "Let's work on the UI"
  "Show me what the dashboard looks like"
  "Take a screenshot and review the layout"
  /skill:ux-collab              (pi)

Dependencies:
  Required:   Playwright MCP, ImageMagick (convert + identify)
  Optional:   Lucid MCP (falls back to Markdown wireframes)

Docs: https://github.com/kylebrodeur/ux-collab
`);
}

function initConfig() {
  const configPath = join(process.cwd(), '.ux-collab.md');
  if (existsSync(configPath)) {
    console.log('  .ux-collab.md already exists — not overwriting.');
    console.log('  To reset: delete .ux-collab.md and run init again.');
    process.exit(0);
  }

  const template = `# UX Collab — Project Config

## Settings

- **defaultUrl**: http://localhost:3000
- **decisionsDoc**: docs/DESIGN_DECISIONS.md
- **lucidShareEmail**: your-email@example.com

## Target Files

<!-- List the files/dirs this project's UI lives in. Examples: -->
<!-- - \`app/_components/\`   UI components -->
<!-- - \`app/globals.css\`    design token layer -->
<!-- - \`tailwind.config.ts\` token wiring -->

## Brand Tokens

<!-- | Token | Value | Usage | -->
<!-- |-------|-------|-------| -->
<!-- | \`--brand-primary\` | \`#000000\` | Headings, primary bg | -->
<!-- | \`--brand-accent\`  | \`#FF0000\` | CTAs, highlights     | -->

## Surface Map

<!-- | Surface | Route | Status | Notes | -->
<!-- |---------|-------|--------|-------| -->
<!-- | Home    | \`/\`   | Active |       | -->

## Open Design Decisions

<!-- 1. Navigation pattern — sidebar vs. top nav -->
<!-- 2. Mobile layout — stacked vs. tabs -->
`;

  writeFileSync(configPath, template, 'utf8');
  console.log('  ✔  Created .ux-collab.md');
  console.log('');
  console.log('  Next: edit .ux-collab.md with your project\'s routes, brand tokens,');
  console.log('        and open design decisions.');
}

// ── Dispatch ──────────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
const cmd = args[0];

switch (cmd) {
  case 'check':
    runScript('check.sh');
    break;
  case 'setup':
    runScript('setup.sh');
    break;
  case 'init':
    initConfig();
    break;
  case 'help':
  case '--help':
  case '-h':
  case undefined:
  default:
    showHelp();
    break;
}
