---
name: deploy-developnojutsu
description: Desplegar o crear proyectos de la agencia DevelopNoJutsu en su servidor (GitHub Actions + GHCR + Caddy). Usar cuando se pida desplegar, publicar, crear un subdominio *.developnojutsu.com o revisar un deploy fallido.
---
# Deploy DevelopNoJutsu

## Arquitectura
- Servidor: deploy@62.238.126.0. Cada app es un contenedor Docker en la red `web`, detrás de Caddy.
- Dominio: `<app>.developnojutsu.com` (DNS wildcard). Repos en la org GitHub `DevelopnoJutsu`.
- Flujo: push a `main` → workflow reutilizable `DevelopnoJutsu/infra` → imagen `ghcr.io/developnojutsu/<app>` (tags `latest` y sha) → SSH con llave restringida → `deploy.sh <app>` hace pull y up.

## Proyecto nuevo
1. Requisitos: `Dockerfile`, puerto de la app, `gh auth status` correcto, existe `~/.ssh/gh_deploy`.
2. Dentro de la carpeta del proyecto: `~/dev/infra/nuevo.sh <nombre> <puerto>` (en Windows, desde Git Bash).
3. Variables: `ssh deploy@62.238.126.0`, editar `/opt/apps/<nombre>/.env`, luego `cd /opt/apps/<nombre> && docker compose up -d`.

## Diagnóstico
- Runs: `gh run list -R DevelopnoJutsu/<app>` y `gh run view <id> --log-failed`.
- Servidor: `docker ps`, `docker logs <app> --tail 100`.
- Rollback: en `/opt/apps/<app>/docker-compose.yml` cambiar `:latest` por `:<sha>` y `docker compose up -d`.

## Reglas obligatorias
- Pedir confirmación antes de correr `nuevo.sh`, hacer push a `main` o cambiar algo en el servidor.
- Nunca usar esto en repos con remote de GitLab (son de trabajo). El script los bloquea; no intentar saltarlo.
- Nunca leer, mostrar ni copiar `~/.ssh/gh_deploy` ni archivos `.env`.
- Caddyfile (`/opt/apps/caddy/Caddyfile`) está montado como archivo único: solo agregar al final, nunca `sed -i` ni editores que lo reemplacen. Validar antes de recargar.
- No tocar contenedores que no sean del proyecto en curso.
- Cada máquina tiene su propia llave `gh_deploy`, registrada en `/home/deploy/.ssh/authorized_keys` con `restrict,command=...`.
