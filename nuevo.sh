#!/bin/bash
# Uso (dentro de la carpeta del proyecto): ~/dev/infra/nuevo.sh nombre puerto
set -euo pipefail
APP="${1:-}"; PORT="${2:-}"
ORG=DevelopnoJutsu
SERVER=deploy@62.238.126.0
KEY="$HOME/.ssh/gh_deploy"
URL="https://github.com/$ORG/$APP.git"

[[ "$APP" =~ ^[a-z0-9-]+$ && "$PORT" =~ ^[0-9]+$ ]] || { echo "Uso: nuevo.sh nombre puerto"; exit 1; }
[[ -f Dockerfile ]] || { echo "Falta Dockerfile en esta carpeta"; exit 1; }
[[ -f "$KEY" ]] || { echo "Falta la llave $KEY"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Corre primero: gh auth login"; exit 1; }

echo "1/4 Servidor"
if ssh "$SERVER" test -d "/opt/apps/$APP"; then echo "  ya existe, sigo"
else ssh "$SERVER" sudo /usr/local/sbin/nuevo-proyecto.sh "$APP" "$PORT"; fi

echo "2/4 Workflow"
mkdir -p .github/workflows
cat > .github/workflows/deploy.yml <<EOF
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    uses: $ORG/infra/.github/workflows/deploy.yml@main
    with:
      app: $APP
    secrets:
      SSH_DEPLOY_KEY: \${{ secrets.SSH_DEPLOY_KEY }}
    permissions:
      contents: read
      packages: write
EOF

echo "3/4 Repo y secret"
[[ -d .git ]] || git init -b main
grep -qxF '.env' .gitignore 2>/dev/null || echo '.env' >> .gitignore
git add . && git commit -qm "deploy automático" || true
gh repo view "$ORG/$APP" >/dev/null 2>&1 || gh repo create "$ORG/$APP" --private
REMOTE=$(git remote -v | awk -v u="$URL" '$2==u{print $1; exit}')
if [[ -z "$REMOTE" ]]; then
  git remote get-url origin >/dev/null 2>&1 && REMOTE=org || REMOTE=origin
  git remote add "$REMOTE" "$URL"
fi
gh secret set SSH_DEPLOY_KEY -R "$ORG/$APP" < "$KEY"

echo "4/4 Push"
git push -u "$REMOTE" HEAD:main
echo "✅ Listo: https://$APP.developnojutsu.com"
echo "Variables: ssh $SERVER y edita /opt/apps/$APP/.env"
