$ErrorActionPreference = "SilentlyContinue"
Write-Host "== DIAG ==" -ForegroundColor Cyan
docker ps
Write-Host "`nAPI health: " (docker inspect -f "{{.State.Health.Status}}" mindlab-api)
Write-Host "DB  health: " (docker inspect -f "{{.State.Health.Status}}" mindlab-db)

Write-Host "`n-- mindlab-api logs (80) --"
docker logs --tail 80 mindlab-api

Write-Host "`n-- mindlab-web logs (80) --"
docker logs --tail 80 mindlab-web

Write-Host "`n-- curl from INSIDE api --"
docker exec mindlab-api sh -lc "curl -fsS http://localhost:8085/health || true"
