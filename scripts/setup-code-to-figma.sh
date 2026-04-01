#!/usr/bin/env bash
# setup-code-to-figma.sh — Install code-to-figma CLI and configure for project
# Usage: bash scripts/setup-code-to-figma.sh

set -euo pipefail

color() { printf '\033[%sm' "$1"; }
reset() { printf '\033[0m'; }
section() { echo ""; color "1;34"; echo "▶ $1"; reset; }
ok() { color "32"; echo "  ✔ $1"; reset; }
info() { color "33"; echo "  ⓘ $1"; reset; }
warn() { color "35"; echo "  ⚠ $1"; reset; }

echo "═════════════════════════════════════════════════════════"
echo "           Code-to-Figma Setup"
echo "═════════════════════════════════════════════════════════"

# ── Step 1: Check Node.js ────────────────────────────────────────────────────
section "Checking Node.js"

if ! command -v node &>/dev/null; then
  echo "  ✘ Node.js not found. Install from https://nodejs.org"
  exit 1
fi

NODE_VER=$(node --version | sed 's/v//')
ok "Node.js $NODE_VER"

# ── Step 2: Install code-to-figma CLI ──────────────────────────────────────────
section "Installing code-to-figma CLI"

if command -v code-to-figma &>/dev/null || [ -f "./node_modules/.bin/code-to-figma" ]; then
  ok "code-to-figma already available"
else
  info "Installing code-to-figma via npm..."
  npm install -g @kylebrodeur/code-to-figma 2>/dev/null || {
    info "Global install failed, trying local install..."
    npm install --save-dev @kylebrodeur/code-to-figma
  }
  ok "code-to-figma installed"
fi

# ── Step 3: Create Configuration ──────────────────────────────────────────────
section "Creating Configuration"

if [ -f ".code-to-figma.json" ]; then
  ok ".code-to-figma.json already exists"
else
  info "Creating .code-to-figma.json..."
  cat > .code-to-figma.json << 'EOF'
{
  "figmaFileKey": "YOUR_FIGMA_FILE_KEY",
  "figmaAccessToken": "YOUR_FIGMA_ACCESS_TOKEN",
  "componentGlob": "src/components/**/*.tsx",
  "tokenMapping": {},
  "outputDir": ".figma",
  "framework": "react",
  "styling": "tailwind",
  "parserOptions": {
    "extractVariantsFromProps": true,
    "detectClassNameUtilities": true,
    "extractSpacing": true
  }
}
EOF
  ok "Created .code-to-figma.json"
  echo ""
  warn "ACTION REQUIRED:"
  echo "  1. Add your Figma file key"
  echo "  2. Add your Figma access token (from figma.com/settings)"
  echo "  3. Customize componentGlob for your project"
fi

# ── Step 4: Update .ux-collab.md ─────────────────────────────────────────────
section "Updating .ux-collab.md"

if [ -f ".ux-collab.md" ]; then
  if grep -q "codeToFigma:" .ux-collab.md 2>/dev/null; then
    ok "code-to-figma already configured in .ux-collab.md"
  else
    info "Adding code-to-figma section to .ux-collab.md..."
    cat >> .ux-collab.md << 'EOF'

# Code-to-Figma Integration
codeToFigma:
  enabled: true
  cliCommand: "npx @kylebrodeur/code-to-figma"
  onBuild: true
EOF
    ok "Updated .ux-collab.md"
  fi
else
  warn ".ux-collab.md not found. Run: npx ux-collab init"
fi

# ── Step 5: Install upstream code-to-figma skill ────────────────────────────
section "Installing code-to-figma skill (upstream)"

if command -v skills &>/dev/null; then
  npx skills add kylebrodeur/code-to-figma 2>/dev/null && ok "Installed kylebrodeur/code-to-figma skill" || warn "Skill install failed — install manually: npx skills add kylebrodeur/code-to-figma"
elif [ -d "~/.agents/skills" ] || [ -d "$HOME/.agents/skills" ]; then
  warn "skills CLI not found but ~/.agents/skills exists — run manually: npx skills add kylebrodeur/code-to-figma"
else
  info "Skipping skill install (skills CLI not detected)"
fi

# ── Step 6: Add .figma to .gitignore ──────────────────────────────────────────
section "Updating .gitignore"

if [ -f ".gitignore" ]; then
  if ! grep -q "^\.figma/$" .gitignore 2>/dev/null; then
    echo ".figma/" >> .gitignore
    ok "Added .figma/ to .gitignore"
  else
    ok ".figma/ already in .gitignore"
  fi
else
  echo ".figma/" > .gitignore
  ok "Created .gitignore with .figma/"
fi

# ── Step 7: Verify Setup ────────────────────────────────────────────────────
section "Verifying Setup"

if command -v code-to-figma &>/dev/null; then
  ok "code-to-figma CLI available"
else
  warn "code-to-figma not in PATH"
  echo "  You can use: npx code-to-figma"
fi

if [ -f ".code-to-figma.json" ]; then
  ok "Configuration file exists"
else
  warn "Configuration file missing"
fi

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              Setup Complete ✓                             ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Quick Start:"
echo "  1. Edit .code-to-figma.json with your Figma credentials"
echo "  2. Scan a component:"
echo "     code-to-figma scan src/components/Button.tsx"
echo "  3. Bundle for Figma plugin:"
echo "     code-to-figma plugin-output -i .figma -o plugin-data.json"
echo ""
echo "Figma Desktop Plugin (one-time setup):"
echo "  1. Clone https://github.com/kylebrodeur/code-to-figma"
echo "  2. Figma Desktop → Plugins → Development → Import plugin from manifest…"
echo "  3. Select packages/plugin/manifest.json from the cloned repo"
echo "  4. Plugin appears under: Plugins → Development → code-to-figma"
echo "  5. Load file → plugin-data.json → Build selected"
echo ""
echo "See: https://github.com/kylebrodeur/code-to-figma"
