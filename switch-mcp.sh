#!/bin/bash
# ===================================================================
# MCP Configuration Switcher
# ===================================================================
# Switches between different MCP server configurations
# All configurations are stored in ./mcp/ directory

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# MCP configurations directory
MCP_DIR="mcp"

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  MCP Configuration Switcher${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo "Select MCP configuration:"
echo ""
echo -e "${GREEN}1${NC} - BASE             (Context7 + Sequential Thinking)      ~600 tokens"
echo -e "${GREEN}2${NC} - SUPABASE         (Base + Supabase MegaCampusAI)        ~2500 tokens"
echo -e "${GREEN}3${NC} - SUPABASE + LEGACY (Base + Supabase + Legacy project)   ~3000 tokens"
echo -e "${GREEN}4${NC} - N8N              (Base + n8n-workflows + n8n-mcp)      ~2500 tokens"
echo -e "${GREEN}5${NC} - FRONTEND         (Base + Playwright + ShadCN)          ~2000 tokens"
echo -e "${GREEN}6${NC} - SERENA           (Base + Serena LSP semantic search)   ~2500 tokens"
echo -e "${GREEN}7${NC} - FULL             (All servers including Serena)        ~6500 tokens"
echo ""
echo -e "${YELLOW}0${NC} - STATUS           (Show current configuration)"
echo ""
read -p "Your choice (0-7): " choice

case "$choice" in
  1)
    config="base"
    desc="BASE (Context7 + Sequential Thinking)"
    ;;
  2)
    config="supabase-only"
    desc="SUPABASE (MegaCampusAI only)"
    ;;
  3)
    config="supabase-full"
    desc="SUPABASE + LEGACY (Both projects)"
    ;;
  4)
    config="n8n"
    desc="N8N (Workflow automation)"
    ;;
  5)
    config="frontend"
    desc="FRONTEND (Playwright + ShadCN)"
    ;;
  6)
    config="serena"
    desc="SERENA (Base + LSP semantic search)"
    ;;
  7)
    config="full"
    desc="FULL (All servers including Serena)"
    ;;
  0)
    echo ""
    echo -e "${BLUE}Current configuration:${NC}"
    if [ -f .mcp.json ]; then
      servers=$(grep -oP '"[^"]+"\s*:\s*\{' .mcp.json | sed 's/"//g' | sed 's/://' | tr '\n' ', ' | sed 's/,$//')
      echo -e "  Active servers: ${GREEN}$servers${NC}"
    else
      echo -e "  ${RED}.mcp.json file not found${NC}"
    fi
    echo ""
    echo "Available configurations:"
    [ -f "$MCP_DIR/.mcp.base.json" ] && echo -e "  ✓ $MCP_DIR/.mcp.base.json"
    [ -f "$MCP_DIR/.mcp.supabase-only.json" ] && echo -e "  ✓ $MCP_DIR/.mcp.supabase-only.json"
    [ -f "$MCP_DIR/.mcp.supabase-full.json" ] && echo -e "  ✓ $MCP_DIR/.mcp.supabase-full.json"
    [ -f "$MCP_DIR/.mcp.n8n.json" ] && echo -e "  ✓ $MCP_DIR/.mcp.n8n.json"
    [ -f "$MCP_DIR/.mcp.frontend.json" ] && echo -e "  ✓ $MCP_DIR/.mcp.frontend.json"
    [ -f "$MCP_DIR/.mcp.serena.json" ] && echo -e "  ✓ $MCP_DIR/.mcp.serena.json"
    [ -f "$MCP_DIR/.mcp.full.json" ] && echo -e "  ✓ $MCP_DIR/.mcp.full.json"
    exit 0
    ;;
  *)
    echo -e "${RED}Invalid choice. Use numbers 0-7.${NC}"
    exit 1
    ;;
esac

# Copy configuration from mcp/ directory to root
SOURCE_FILE="$MCP_DIR/.mcp.$config.json"
if [ -f "$SOURCE_FILE" ]; then
  cp "$SOURCE_FILE" .mcp.json
  echo ""
  echo -e "${GREEN}✅ Switched to: $desc${NC}"
  echo -e "   Source: ${BLUE}$SOURCE_FILE${NC}"
  echo ""
  echo -e "${YELLOW}⚠️  IMPORTANT: Restart Claude Code to apply changes!${NC}"
  echo ""
else
  echo -e "${RED}❌ File $SOURCE_FILE not found${NC}"
  exit 1
fi
