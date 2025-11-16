#!/usr/bin/env bash
# Installer
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Required hash
REQUIRED_HASH="bb30f0ac65d69ee8ec3fc22f1214f3c5cdf40b42c5a05c1b02da314bc9e4a0ad"

# Verify
if [ -z "$SPECFLOW_KEY" ]; then
    echo -e "${RED}Access denied${NC}"
    echo -e "${YELLOW}Set: export SPECFLOW_KEY=\"****\"${NC}"
    exit 1
fi

# Hash check
INPUT_HASH=$(echo -n "$SPECFLOW_KEY" | sha256sum | awk '{print $1}')

if [ "$INPUT_HASH" != "$REQUIRED_HASH" ]; then
    echo -e "${RED}Invalid key${NC}"
    exit 1
fi

# Config
CLAUDE_CONFIG_DIRS=(
    "$HOME/.claude"
    "$HOME/.config/claude"
)

CLAUDE_CONFIG_DIR=""
for dir in "${CLAUDE_CONFIG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        CLAUDE_CONFIG_DIR="$dir"
        break
    fi
done

if [ -z "$CLAUDE_CONFIG_DIR" ]; then
    CLAUDE_CONFIG_DIR="$HOME/.claude"
fi

SKILL_DIR="$CLAUDE_CONFIG_DIR/skills/specflow"

if [ ! -d "$SKILL_DIR" ]; then
    mkdir -p "$SKILL_DIR"
fi

# Download
SKILL_URL="https://raw.githubusercontent.com/feizaiguai/gongju1/main/.claude/skills/specflow/SKILL.md"
SKILL_FILE="$SKILL_DIR/SKILL.md"

echo -e "${GREEN}Installing...${NC}"

if command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -fsSL"
    DOWNLOAD_OUTPUT="-o"
elif command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -q"
    DOWNLOAD_OUTPUT="-O"
else
    echo -e "${RED}curl or wget not found${NC}"
    exit 1
fi

if $DOWNLOAD_CMD "$SKILL_URL" $DOWNLOAD_OUTPUT "$SKILL_FILE"; then
    chmod 644 "$SKILL_FILE"
else
    echo -e "${RED}Failed${NC}"
    exit 1
fi

if [ ! -f "$SKILL_FILE" ]; then
    echo -e "${RED}Failed${NC}"
    exit 1
fi

echo -e "${GREEN}Done${NC}"
