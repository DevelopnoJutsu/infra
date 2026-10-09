# Infra DevelopNoJutsu

Servidor Hetzner 62.238.126.0, usuario `deploy`. Apps en Docker, red `web`, detrás de Caddy.

## Desplegar un proyecto
Dentro de la carpeta del proyecto (con Dockerfile): `~/dev/infra/nuevo.sh nombre puerto`.
Cada push a `main` despliega solo. Variables en el servidor: `/opt/apps/<nombre>/.env`.

## Cómo funciona
- GitHub Actions construye la imagen → `ghcr.io/developnojutsu/<app>` → SSH al servidor.
- La llave `~/.ssh/gh_deploy` solo puede ejecutar `/opt/apps/bin/deploy.sh <app>` (sin terminal).
- Proyectos nuevos en servidor: `sudo /usr/local/sbin/nuevo-proyecto.sh <app> <puerto>`.
- Dominio: `<app>.developnojutsu.com` (DNS wildcard en Namecheap).

## Reglas
- Nunca mostrar, copiar ni subir el contenido de `~/.ssh/gh_deploy` ni archivos `.env`.
- Caddyfile (`/opt/apps/caddy/Caddyfile`) está montado como archivo único: solo agregar al final, nunca `sed -i` ni editores que lo reemplacen.
- No tocar contenedores que no sean del proyecto en curso.
