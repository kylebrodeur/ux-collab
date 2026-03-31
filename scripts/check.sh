#!/usr/bin/env bash
# check.sh — verify all ux-collab dependencies are installed and ready
# Usage: bash scripts/check.sh [--json]
#
# Exit codes:
#   0  all required deps OK (optional deps may be missing)
#   1  one or more required deps missing

set -euo pipefail

JSON_OUTPUT=false
[[ "${1:-}" == "--json" ]] && JSON_OUTPUT=true

# ── Counters ──────────────────────────────────────────────────────────────────
PASS=0
FAIL=0
WARN=0
declare -a ISSUES=()
declare -a WARNINGS=()
declare -a PASSED=()

ok()   { echo "  ✔  $1"; PASS=$((PASS+1)); PASSED+=("$1"); }
fail() { echo "  ✘  $1"; FAIL=$((FAIL+1)); ISSUES+=("$1"); }
warn() { echo "  ⚠  $1"; WARN=$((WARN+1)); WARNINGS+=("$1"); }
section() { echo ""; echo "── $1 ──────────────────────────────────────────"; }

echo "═══ ux-collab dependency check ═══"

# ── Node.js ───────────────────────────────────────────────────────────────────
section "Runtime"

if command -v node &>/dev/null; then
  NODE_VER=$(node --version 2>/dev/null | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [[ "$NODE_MAJOR" -ge 20 ]]; then
    ok "Node.js v${NODE_VER} (≥20 required)"
  else
    fail "Node.js v${NODE_VER} — too old (need ≥20). Install: https://nodejs.org"
  fi
else
  fail "Node.js not found. Install: https://nodejs.org"
fi

# ── ImageMagick ───────────────────────────────────────────────────────────────
section "ImageMagick (required for screenshot optimization)"

if command -v convert &>/dev/null; then
  IM_VER=$(convert --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1)
  ok "convert ${IM_VER:-found}"
else
  fail "ImageMagick 'convert' not found"
  ISSUES+=("  Fix: brew install imagemagick   (macOS)")
  ISSUES+=("       sudo apt install imagemagick  (Ubuntu/Debian)")
fi

if command -v identify &>/dev/null; then
  ok "identify (ImageMagick)"
else
  fail "ImageMagick 'identify' not found (usually bundled with convert)"
fi

# ── Playwright MCP ────────────────────────────────────────────────────────────
section "Playwright MCP (required)"

PLAYWRIGHT_FOUND=false

# Check 1: Claude Code enabledPlugins in ~/.claude/settings.json
CLAUDE_SETTINGS="${HOME}/.claude/settings.json"
if [[ -f "$CLAUDE_SETTINGS" ]]; then
  if python3 -c "
import json, sys
try:
  d = json.load(open('$CLAUDE_SETTINGS'))
  plugins = d.get('enabledPlugins', {})
  found = any('playwright' in k.lower() for k in plugins.keys() if plugins[k])
  sys.exit(0 if found else 1)
except Exception: sys.exit(1)
" 2>/dev/null; then
    ok "Playwright plugin enabled in ~/.claude/settings.json"
    PLAYWRIGHT_FOUND=true
  fi
fi

# Check 2: VS Code user mcp.json (WSL path uses "servers" key)
if [[ "$PLAYWRIGHT_FOUND" == false ]]; then
  VSCODE_MCP=$(find /mnt/c/Users -maxdepth 5 -path "*/AppData/Roaming/Code/User/mcp.json" 2>/dev/null | head -1 || true)
  if [[ -n "${VSCODE_MCP:-}" ]]; then
    if python3 -c "
import json, sys
try:
  d = json.load(open('${VSCODE_MCP}'))
  servers = {**d.get('servers', {}), **d.get('mcpServers', {})}
  found = any('playwright' in k.lower() for k in servers.keys())
  sys.exit(0 if found else 1)
except Exception: sys.exit(1)
" 2>/dev/null; then
      ok "Playwright MCP found in VS Code user mcp.json"
      PLAYWRIGHT_FOUND=true
    fi
  fi
fi

# Check 3: .mcp.json or mcp.json in current dir or project root
if [[ "$PLAYWRIGHT_FOUND" == false ]]; then
  for MCP_FILE in ".mcp.json" "mcp.json" "${HOME}/.mcp.json"; do
    if [[ -f "$MCP_FILE" ]]; then
      if python3 -c "
import json, sys
try:
  d = json.load(open('$MCP_FILE'))
  servers = {**d.get('servers', {}), **d.get('mcpServers', {})}
  found = any('playwright' in k.lower() for k in servers.keys())
  sys.exit(0 if found else 1)
except Exception: sys.exit(1)
" 2>/dev/null; then
        ok "Playwright MCP server found in ${MCP_FILE}"
        PLAYWRIGHT_FOUND=true
        break
      fi
    fi
  done
fi

if [[ "$PLAYWRIGHT_FOUND" == false ]]; then
  fail "Playwright MCP not detected"
  ISSUES+=("  Fix (Claude Code): claude plugin install playwright@claude-plugins-official")
  ISSUES+=("  Fix (manual MCP):  add playwright server to .mcp.json — see README.md")
fi

# ── Lucid MCP ─────────────────────────────────────────────────────────────────
section "Lucid MCP (optional — Markdown wireframe fallback used when absent)"

LUCID_FOUND=false

# Check Claude Code enabledPlugins
if [[ -f "$CLAUDE_SETTINGS" ]]; then
  if python3 -c "
import json, sys
try:
  d = json.load(open('$CLAUDE_SETTINGS'))
  plugins = d.get('enabledPlugins', {})
  found = any('lucid' in k.lower() for k in plugins.keys() if plugins[k])
  sys.exit(0 if found else 1)
except Exception: sys.exit(1)
" 2>/dev/null; then
    ok "Lucid plugin enabled in ~/.claude/settings.json"
    LUCID_FOUND=true
  fi
fi

# Check 2: VS Code user mcp.json
if [[ "$LUCID_FOUND" == false ]]; then
  VSCODE_MCP=$(find /mnt/c/Users -maxdepth 5 -path "*/AppData/Roaming/Code/User/mcp.json" 2>/dev/null | head -1 || true)
  if [[ -n "${VSCODE_MCP:-}" ]]; then
    if python3 -c "
import json, sys
try:
  d = json.load(open('${VSCODE_MCP}'))
  servers = {**d.get('servers', {}), **d.get('mcpServers', {})}
  found = any('lucid' in k.lower() for k in servers.keys())
  sys.exit(0 if found else 1)
except Exception: sys.exit(1)
" 2>/dev/null; then
      ok "Lucid MCP found in VS Code user mcp.json"
      LUCID_FOUND=true
    fi
  fi
fi

# Check 3: .mcp.json or mcp.json in current dir or project root
if [[ "$LUCID_FOUND" == false ]]; then
  for MCP_FILE in ".mcp.json" "mcp.json" "${HOME}/.mcp.json"; do
    if [[ -f "$MCP_FILE" ]]; then
      if python3 -c "
import json, sys
try:
  d = json.load(open('$MCP_FILE'))
  servers = {**d.get('servers', {}), **d.get('mcpServers', {})}
  found = any('lucid' in k.lower() for k in servers.keys())
  sys.exit(0 if found else 1)
except Exception: sys.exit(1)
" 2>/dev/null; then
        ok "Lucid MCP server found in ${MCP_FILE}"
        LUCID_FOUND=true
        break
      fi
    fi
  done
fi

if [[ "$LUCID_FOUND" == false ]]; then
  warn "Lucid MCP not detected — wireframes will use Markdown fallback (Step 3b)"
  WARNINGS+=("  Info: install Lucid MCP to enable diagram creation in Step 3")
fi

# ── Project config ────────────────────────────────────────────────────────────
section "Project config (optional)"

if [[ -f ".ux-collab.md" ]]; then
  ok ".ux-collab.md found (project-specific config)"
else
  warn ".ux-collab.md not found — skill will use defaults (auto-discover routes, no brand tokens)"
  WARNINGS+=("  Info: run 'npx ux-collab init' to create a starter .ux-collab.md")
fi

# ── optimize-screenshot.sh ────────────────────────────────────────────────────
section "Helper scripts"

# Find the script relative to this check.sh location or the installed skill dir
SCRIPT_DIRS=(
  "$(dirname "${BASH_SOURCE[0]}")/../skills/ux-collab"
  "${HOME}/.agents/skills/ux-collab"
  "${HOME}/.pi/agent/skills/ux-collab"
)

SCRIPT_FOUND=false
for DIR in "${SCRIPT_DIRS[@]}"; do
  if [[ -x "${DIR}/optimize-screenshot.sh" ]]; then
    ok "optimize-screenshot.sh found at ${DIR}/optimize-screenshot.sh"
    SCRIPT_FOUND=true
    break
  fi
done

if [[ "$SCRIPT_FOUND" == false ]]; then
  fail "optimize-screenshot.sh not found or not executable"
  ISSUES+=("  Fix: chmod +x skills/ux-collab/optimize-screenshot.sh")
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════"
echo "  ✔  Passed:   ${PASS}"
echo "  ⚠  Warnings: ${WARN}"
echo "  ✘  Failed:   ${FAIL}"
echo "══════════════════════════════════════════"

if [[ ${#ISSUES[@]} -gt 0 ]]; then
  echo ""
  echo "Issues to fix:"
  for issue in "${ISSUES[@]}"; do
    echo "$issue"
  done
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo ""
  echo "Recommendations:"
  for w in "${WARNINGS[@]}"; do
    echo "$w"
  done
fi

echo ""
if [[ "$FAIL" -gt 0 ]]; then
  echo "  → Run: bash scripts/setup.sh  to attempt automatic fixes"
  if [[ "$JSON_OUTPUT" == true ]]; then
    python3 -c "
import json
print(json.dumps({'status':'fail','passed':${PASS},'warnings':${WARN},'failed':${FAIL}}))
"
  fi
  exit 1
else
  echo "  → All required dependencies present. Ready to run ux-collab."
  if [[ "$JSON_OUTPUT" == true ]]; then
    python3 -c "
import json
print(json.dumps({'status':'ok','passed':${PASS},'warnings':${WARN},'failed':${FAIL}}))
"
  fi
  exit 0
fi
