MindLab – Deployment

Requirements
- Docker Desktop (Windows/macOS) or Docker Engine + docker compose plugin (Linux)
- Open ports: 80 (web), 5433 (Postgres)

How to run (local or server)
1) cd deploy/tools
2) ./up.ps1
3) Visit http://localhost/ and http://localhost/api/health

How to stop
- cd deploy/tools
- ./down.ps1

Common changes
- Edit deploy/.env (POSTGRES_* creds, CORS_ORIGIN)
- Change host ports in deploy/docker-compose.yml if 80/5433 are busy

Health endpoints
- Web:   http://localhost/          (serves frontend and calls /api/health)
- API:   http://localhost/api/health
- DB:    http://localhost/api/db/health

