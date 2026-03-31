#!/usr/bin/env bash
# setup.sh — install and configure ux-collab dependencies
# Usage: bash scripts/setup.sh
#
# What this does:
#   1. Checks Node.js version
#   2. Installs ImageMagick if missing (macOS: brew, Ubuntu/Debian: apt)
#   3. Guides Playwright MCP setup if not detected
#   4. Creates a .ux-collab.md project config if one doesn't exist
#   5. Runs check.sh to confirm everything passed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

section() { echo ""; echo "── $1 ──────────────────────────────────────────"; }
ok()      { echo "  ✔  $1"; }
info()    { echo "  ℹ  $1"; }
warn()    { echo "  ⚠  $1"; }
fail()    { echo "  ✘  $1"; }

echo "═══ ux-collab setup ═══"

# ── Node.js ───────────────────────────────────────────────────────────────────
section "Node.js"

if command -v node &>/dev/null; then
  NODE_VER=$(node --version | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [[ "$NODE_MAJOR" -ge 20 ]]; then
    ok "Node.js v${NODE_VER} — OK"
  else
    fail "Node.js v${NODE_VER} is too old (need ≥20)"
    echo ""
    echo "  Install Node.js 20+ from: https://nodejs.org"
    echo "  Or with fnm: fnm install 20 && fnm use 20"
    echo ""
    echo "  Setup cannot continue without Node.js 20+."
    exit 1
  fi
else
  fail "Node.js not found"
  echo ""
  echo "  Install from: https://nodejs.org"
  echo "  Or with fnm:  curl -fsSL https://fnm.vercel.app/install | bash"
  echo ""
  echo "  Setup cannot continue without Node.js 20+."
  exit 1
fi

# ── ImageMagick ───────────────────────────────────────────────────────────────
section "ImageMagick"

if command -v convert &>/dev/null && command -v identify &>/dev/null; then
  IM_VER=$(convert --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1)
  ok "ImageMagick ${IM_VER:-found} — already installed"
else
  info "ImageMagick not found — attempting install..."
  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      if command -v brew &>/dev/null; then
        echo "  Running: brew install imagemagick"
        brew install imagemagick
        ok "ImageMagick installed via Homebrew"
      else
        fail "Homebrew not found — cannot auto-install ImageMagick"
        echo "  Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo "  Then run:         brew install imagemagick"
      fi
      ;;
    Linux)
      if command -v apt-get &>/dev/null; then
        echo "  Running: sudo apt-get install -y imagemagick"
        sudo apt-get install -y imagemagick
        ok "ImageMagick installed via apt"
      elif command -v dnf &>/dev/null; then
        echo "  Running: sudo dnf install -y ImageMagick"
        sudo dnf install -y ImageMagick
        ok "ImageMagick installed via dnf"
      elif command -v pacman &>/dev/null; then
        echo "  Running: sudo pacman -S --noconfirm imagemagick"
        sudo pacman -S --noconfirm imagemagick
        ok "ImageMagick installed via pacman"
      else
        fail "Cannot detect package manager — install ImageMagick manually"
        echo "  See: https://imagemagick.org/script/download.php"
      fi
      ;;
    *)
      fail "Unsupported OS '${OS}' — install ImageMagick manually"
      echo "  See: https://imagemagick.org/script/download.php"
      ;;
  esac
fi

# ── optimize-screenshot.sh ────────────────────────────────────────────────────
section "optimize-screenshot.sh"

SCRIPT_SRC="${PACKAGE_ROOT}/skills/ux-collab/optimize-screenshot.sh"
SKILL_INSTALL_DIR="${HOME}/.agents/skills/ux-collab"

if [[ -f "$SCRIPT_SRC" ]]; then
  chmod +x "$SCRIPT_SRC"
  ok "optimize-screenshot.sh is executable at ${SCRIPT_SRC}"
else
  warn "optimize-screenshot.sh not found at expected location: ${SCRIPT_SRC}"
fi

# If skill is being used from the installed location, ensure the script is there too
if [[ -d "$SKILL_INSTALL_DIR" ]] && [[ ! -f "${SKILL_INSTALL_DIR}/optimize-screenshot.sh" ]]; then
  info "Copying optimize-screenshot.sh to installed skill dir..."
  cp "$SCRIPT_SRC" "${SKILL_INSTALL_DIR}/optimize-screenshot.sh"
  chmod +x "${SKILL_INSTALL_DIR}/optimize-screenshot.sh"
  ok "Copied to ${SKILL_INSTALL_DIR}/optimize-screenshot.sh"
fi

# ── Playwright MCP guidance ───────────────────────────────────────────────────
section "Playwright MCP"

PLAYWRIGHT_FOUND=false
CLAUDE_SETTINGS="${HOME}/.claude/settings.json"

# Check Claude Code plugin
if [[ -f "$CLAUDE_SETTINGS" ]]; then
  if python3 -c "
import json, sys
d = json.load(open('$CLAUDE_SETTINGS'))
plugins = d.get('enabledPlugins', {})
found = any('playwright' in k.lower() for k in plugins.keys() if plugins[k])
sys.exit(0 if found else 1)
" 2>/dev/null; then
    ok "Playwright plugin already enabled in Claude Code"
    PLAYWRIGHT_FOUND=true
  fi
fi

# Check .mcp.json
if [[ "$PLAYWRIGHT_FOUND" == false ]]; then
  for MCP_FILE in ".mcp.json" "mcp.json"; do
    if [[ -f "$MCP_FILE" ]]; then
      if python3 -c "
import json, sys
d = json.load(open('$MCP_FILE'))
found = any('playwright' in k.lower() for k in d.get('mcpServers', {}).keys())
sys.exit(0 if found else 1)
" 2>/dev/null; then
        ok "Playwright MCP server found in ${MCP_FILE}"
        PLAYWRIGHT_FOUND=true
        break
      fi
    fi
  done
fi

if [[ "$PLAYWRIGHT_FOUND" == false ]]; then
  warn "Playwright MCP not detected — setup required (cannot auto-install)"
  echo ""
  echo "  ── Option A: Claude Code plugin (recommended) ──"
  echo "  claude plugin install playwright@claude-plugins-official"
  echo ""
  echo "  ── Option B: Manual MCP server via .mcp.json ──"
  echo "  Add to your project's .mcp.json:"
  echo '  {'
  echo '    "mcpServers": {'
  echo '      "playwright": {'
  echo '        "command": "npx",'
  echo '        "args": ["@playwright/mcp@latest"]'
  echo '      }'
  echo '    }'
  echo '  }'
  echo ""
  echo "  See: https://github.com/microsoft/playwright-mcp"
  echo ""
  echo "  ── If MCP servers start but hang or show pnpm path errors ──"
  if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    echo "  npx @kylebrodeur/mcp-wsl-setup   ← fixes pnpm/fnm path issues in WSL"
  else
    echo "  npx @kylebrodeur/mcp-mac-setup   ← fixes pnpm path issues on macOS"
    echo "  npx @kylebrodeur/mcp-wsl-setup   ← fixes pnpm/fnm path issues in WSL"
  fi
fi

# ── Lucid MCP guidance ────────────────────────────────────────────────────────
section "Lucid MCP (optional)"

LUCID_FOUND=false

if [[ -f "$CLAUDE_SETTINGS" ]]; then
  if python3 -c "
import json, sys
d = json.load(open('$CLAUDE_SETTINGS'))
plugins = d.get('enabledPlugins', {})
found = any('lucid' in k.lower() for k in plugins.keys() if plugins[k])
sys.exit(0 if found else 1)
" 2>/dev/null; then
    ok "Lucid plugin already enabled in Claude Code"
    LUCID_FOUND=true
  fi
fi

if [[ "$LUCID_FOUND" == false ]]; then
  for MCP_FILE in ".mcp.json" "mcp.json"; do
    if [[ -f "$MCP_FILE" ]]; then
      if python3 -c "
import json, sys
d = json.load(open('$MCP_FILE'))
found = any('lucid' in k.lower() for k in d.get('mcpServers', {}).keys())
sys.exit(0 if found else 1)
" 2>/dev/null; then
        ok "Lucid MCP found in ${MCP_FILE}"
        LUCID_FOUND=true
        break
      fi
    fi
  done
fi

if [[ "$LUCID_FOUND" == false ]]; then
  info "Lucid MCP not detected — skill will use Markdown wireframe fallback (Step 3b)"
  echo "  To enable Lucid wireframes:"
  echo "  claude plugin install lucid@claude-plugins-official"
  echo "  (or add lucid MCP server to your .mcp.json)"
fi

# ── Project config (.ux-collab.md) ────────────────────────────────────────────
section "Project config"

if [[ -f ".ux-collab.md" ]]; then
  ok ".ux-collab.md already exists"
else
  info ".ux-collab.md not found — creating starter config..."
  cat > .ux-collab.md << 'CONFIGEOF'
# UX Collab — Project Config

## Settings

- **defaultUrl**: http://localhost:3000
- **decisionsDoc**: docs/DESIGN_DECISIONS.md
- **lucidShareEmail**: your-email@example.com

## Target Files

<!-- List the files/dirs this project's UI lives in. Examples: -->
<!-- - `app/_components/`  UI components -->
<!-- - `app/globals.css`    design token layer -->
<!-- - `tailwind.config.ts` token wiring -->

## Brand Tokens

<!-- | Token | Value | Usage | -->
<!-- |-------|-------|-------| -->
<!-- | `--brand-primary` | `#000000` | Headings, primary bg | -->
<!-- | `--brand-accent`  | `#FF0000` | CTAs, highlights     | -->

## Surface Map

<!-- | Surface | Route | Status | Notes | -->
<!-- |---------|-------|--------|-------| -->
<!-- | Home    | `/`   | Active |       | -->

## Open Design Decisions

<!-- 1. Navigation pattern — sidebar vs. top nav -->
<!-- 2. Mobile layout — stacked vs. tabs -->
CONFIGEOF
  ok "Created .ux-collab.md — edit it with your project's routes, tokens, and decisions"
fi

# ── Final check ───────────────────────────────────────────────────────────────
section "Verification"
echo ""
echo "Running full dependency check..."
echo ""

if bash "${SCRIPT_DIR}/check.sh"; then
  echo ""
  echo "═══ Setup complete ═══"
  echo ""
  echo "Next steps:"
  echo "  1. Edit .ux-collab.md with your project's routes, brand tokens, and decisions"
  echo "  2. Start your dev server"
  echo "  3. Tell your agent: 'Let's work on the UI' or 'Take a screenshot'"
  echo ""
else
  echo ""
  echo "═══ Setup complete with issues ═══"
  echo ""
  echo "Review the failures above and fix them before running ux-collab."
  echo ""
  exit 1
fi
