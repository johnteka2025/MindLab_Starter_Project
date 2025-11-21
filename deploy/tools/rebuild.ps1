$ErrorActionPreference = 'Stop'
Push-Location 'C:\Projects\MindLab_Starter_Project\deploy'
try {
  docker compose --project-name mindlab -f .\docker-compose.yml --env-file .\.env build --no-cache
  docker compose --project-name mindlab -f .\docker-compose.yml --env-file .\.env up -d
} finally { Pop-Location }
