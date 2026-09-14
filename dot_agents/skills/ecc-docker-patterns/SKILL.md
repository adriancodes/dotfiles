---
name: ecc-docker-patterns
description: "Use when creating or reviewing Dockerfiles and Compose services, testing installers across Linux distributions, or planning accurate native macOS and Windows validation."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/docker-patterns/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for docker patterns; adapted for explicit local scope and evidence-backed use."
---

# Docker Patterns — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Docker Patterns

Docker and Docker Compose best practices for containerized development.

## Docker Compose for Local Development

### Standard Web App Stack

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      target: dev                     # Use dev stage of multi-stage Dockerfile
    ports:
      - "127.0.0.1:3000:3000"
    volumes:
      - .:/app                        # Bind mount for hot reload
      - /app/node_modules             # Anonymous volume -- preserves container deps
    environment:
      - DATABASE_URL=postgres://postgres:${POSTGRES_PASSWORD:?set a local development password}@db:5432/app_dev
      - REDIS_URL=redis://redis:6379/0
      - NODE_ENV=development
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    command: npm run dev

  db:
    image: postgres:16-alpine
    ports:
      - "127.0.0.1:5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: "${POSTGRES_PASSWORD:?set a local development password}"
      POSTGRES_DB: app_dev
    volumes:
      - pgdata:/var/lib/postgresql/data
      # Optional: mount a reviewed project-owned initialization SQL file here.
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "127.0.0.1:6379:6379"
    volumes:
      - redisdata:/data

  mailpit:                            # Local email testing
    image: axllent/mailpit
    ports:
      - "127.0.0.1:8025:8025"                   # Web UI
      - "127.0.0.1:1025:1025"                   # SMTP

volumes:
  pgdata:
  redisdata:
```

### Development vs Production Dockerfile

```dockerfile
# Stage: dependencies
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Stage: dev (hot reload, debug tools)
FROM node:22-alpine AS dev
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Stage: build
FROM node:22-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build && npm prune --omit=dev

# Stage: production (minimal image)
FROM node:22-alpine AS production
WORKDIR /app
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001
USER appuser
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/package.json ./
ENV NODE_ENV=production
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/server.js"]
```

### Override Files

```yaml
# docker-compose.override.yml (auto-loaded, dev-only settings)
services:
  app:
    environment:
      - DEBUG=app:*
      - LOG_LEVEL=debug
    ports:
      - "127.0.0.1:9229:9229"                   # Node.js debugger

# docker-compose.prod.yml (explicit for production)
services:
  app:
    build:
      target: production
    restart: always
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
```

```bash
# Development (auto-loads override)
docker compose up

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Networking

### Service Discovery

Services in the same Compose network resolve by service name:
```
# From "app" container:
postgres://postgres:${POSTGRES_PASSWORD:?set a local development password}@db:5432/app_dev    # "db" resolves to the db container
redis://redis:6379/0                             # "redis" resolves to the redis container
```

### Custom Networks

```yaml
services:
  frontend:
    networks:
      - frontend-net

  api:
    networks:
      - frontend-net
      - backend-net

  db:
    networks:
      - backend-net              # Only reachable from api, not frontend

networks:
  frontend-net:
  backend-net:
```

### Exposing Only What's Needed

```yaml
services:
  db:
    ports:
      - "127.0.0.1:5432:5432"   # Only accessible from host, not network
    # Omit ports entirely in production -- accessible only within Docker network
```

## Volume Strategies

```yaml
volumes:
  # Named volume: persists across container restarts, managed by Docker
  pgdata:

  # Bind mount: maps host directory into container (for development)
  # - ./src:/app/src

  # Anonymous volume: preserves container-generated content from bind mount override
  # - /app/node_modules
```

### Common Patterns

```yaml
services:
  app:
    volumes:
      - .:/app                   # Source code (bind mount for hot reload)
      - /app/node_modules        # Protect container's node_modules from host
      - /app/.next               # Protect build cache

  db:
    volumes:
      - pgdata:/var/lib/postgresql/data          # Persistent data
      # Optional project initialization SQL must be reviewed; do not auto-run migrations.
```

## Container Security

### Dockerfile Hardening

```dockerfile
# 1. Use specific tags (never :latest)
FROM node:22.12-alpine3.20

# 2. Run as non-root
RUN addgroup -g 1001 -S app && adduser -S app -u 1001
USER app

# 3. Drop capabilities (in compose)
# 4. Read-only root filesystem where possible
# 5. No secrets in image layers
```

### Compose Security

```yaml
services:
  app:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /app/.cache
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE          # Only if binding to ports < 1024
```

### Secret Management

Keep secrets out of image layers, build arguments, and committed Compose files. Runtime environment injection is convenient for a local fixture but is inspectable; prefer the platform secret store where available.

```yaml
# Separate illustrative Compose fragment. Supply a private file outside version control.
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
secrets:
  db_password:
    file: ${DB_PASSWORD_FILE:?supply an approved private secret file}
```

Compose file-backed secrets are mounts, not an encrypted secret-management system. The caller controls file permissions, credentials, and approval to start a container.

## Hardened CLI Installer Harnesses

Use containers to test installer behavior against disposable project copies without allowing the test to mutate the source checkout.

### Respect the Platform Boundary

- Run real containers for Linux distributions such as Debian and Ubuntu.
- macOS cannot run as a Docker container because Docker shares a Linux kernel. Run the same shell-free test entry point natively on macOS.
- Windows containers require a Windows Docker engine. Run platform-independent logic on a native Windows CI runner and reserve Windows containers for a Windows host.
- Keep a native Ubuntu/macOS/Windows CI matrix for host-specific paths, command shims, quoting, and filesystem behavior.

Do not claim that a Linux container validates macOS or Windows behavior.

### Enforce the Isolation Contract

- Pin base images by immutable digest and pin installed CLI versions.
- Run as a non-root numeric UID/GID when distro account names differ.
- Mount the repository and source project read-only.
- Copy the source project into a writable `tmpfs` workspace before any mutation.
- Mount `/workspace` with `noexec`, UID/GID 1000, and `mode=0700` so only the
  container user can inspect project data.
- Keep npm and npx's executable cache at `NPM_CONFIG_CACHE=/tmp/npm-cache` on
  the executable `/tmp` mount. Its default size is 2 GiB and can be adjusted
  for the local workload; separately size the private workspace mount.
- Set `read_only: true`, `no-new-privileges:true`, `cap_drop: [ALL]`, and a finite `pids_limit`.
- Keep the default real-CLI services on `network_mode: none`. Add network access
  only through a visibly named opt-in service for an authenticated provider
  session; never make it an accidental environment-driven default.
- Create only the writable temporary paths the tool needs.
- Do not pass host credentials into the container by default.
- Require explicit authorization for any local installer experiment; review its supported modes rather than inventing a universal CLI contract.
- Use argument arrays or `spawnSync(..., { shell: false })` for cross-platform runners. Never interpolate project paths into a shell command.

### Self-Contained Isolation Reference

The upstream ECC plugin installer, terminal integration, and target-specific fixtures are intentionally not imported. They are not prerequisites for Docker guidance.

```yaml
# Local review-only template: the caller supplies a reviewed image and source directory.
services:
  isolated:
    image: ${REVIEW_IMAGE:?supply a reviewed image reference}
    user: "1000:1000"
    network_mode: none
    read_only: true
    security_opt: ["no-new-privileges:true"]
    cap_drop: ["ALL"]
    pids_limit: 128
    volumes:
      - type: bind
        source: ${REVIEW_SOURCE:?supply the intended local source directory}
        target: /source
        read_only: true
    tmpfs:
      - /workspace:rw,noexec,nosuid,nodev,uid=1000,gid=1000,mode=0700,size=256m
      - /tmp:rw,nosuid,nodev,uid=1000,gid=1000,mode=0700,size=256m
```

The fragment does not install a CLI, execute a fixture, mount credentials, or invoke a harness. A caller-authorized local command must choose its working copy and entry point explicitly. `noexec` limits direct execution but is not a sandbox against an interpreter reading a script. Pin the selected image by digest when reproducibility requires it.

## .dockerignore

```
node_modules
.git
.env
.env.*
dist
coverage
*.log
.next
.cache
docker-compose*.yml
Dockerfile*
README.md
tests/
```

## Debugging

### Local Command Reference

These commands require a separately authorized local Docker target. They are examples, not a startup, rebuild, cleanup, or log-capture sequence.

```bash
docker compose ps
docker compose top
docker inspect <exact-container-name>
docker image inspect <exact-image-reference>
```

For a read-only review, request redacted excerpts of existing logs and inspect the supplied Compose model. Opening container shells, querying databases, rebuilding images, following logs, and stopping containers are separate actions. Do not use global prune, cache-reset builds, or volume deletion as a troubleshooting default.

### Debugging Network Issues

```bash
# Check DNS resolution inside container
docker compose exec app nslookup db

# Check connectivity
docker compose exec app wget -qO- http://api:3000/health

# Inspect network
docker network ls
docker network inspect <project>_default
```

## Anti-Patterns

```
# Review availability and operational requirements before choosing an orchestrator.
# A single-host Compose deployment may fit a workload; Kubernetes is not mandatory.

# BAD: Storing data in containers without volumes
# Writable layers survive container restart but are lost on container removal/recreation.

# BAD: Running as root
# Always create and use a non-root user

# BAD: Using :latest tag
# Pin to specific versions for reproducible builds

# BAD: One giant container with all services
# Separate concerns: one process per container

# BAD: Putting secrets in docker-compose.yml
# Use .env files (gitignored) or Docker secrets
```
