#!/bin/bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)/skills/deploy-developnojutsu"
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/deploy-developnojutsu
cp -r "$SRC" ~/.claude/skills/
echo "✅ Skill instalado en ~/.claude/skills/deploy-developnojutsu"
