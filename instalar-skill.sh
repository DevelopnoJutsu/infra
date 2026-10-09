#!/bin/bash
# Installs the deploy skill and the .env-blocking hook into ~/.claude (macOS, Linux, Git Bash on Windows).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/skills/deploy-developnojutsu"
HOOK="$ROOT/claude/block-env-files.sh"

mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/deploy-developnojutsu
cp -r "$SRC" ~/.claude/skills/
echo "✅ Skill instalado en ~/.claude/skills/deploy-developnojutsu"

mkdir -p ~/.claude/hooks
cp "$HOOK" ~/.claude/hooks/block-env-files.sh
chmod +x ~/.claude/hooks/block-env-files.sh
echo "✅ Hook instalado en ~/.claude/hooks/block-env-files.sh"

echo "ℹ️  Para activarlo, fusiona claude/settings.example.json con ~/.claude/settings.json (no se modifica automáticamente)."
