# cd to deploy root and follow logs
Set-Location (Join-Path $PSScriptRoot '..')
docker compose -f .\prod\docker-compose.prod.yml logs -f --tail=100
