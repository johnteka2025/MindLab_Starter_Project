# Kids tracker maintenance rule

1. Start from a clean repository.
2. Restore tools\backend.pid and backend\src\data\progress.json before cleanliness checks.
3. Update tracker status only when an artifact exists or explicit approval has been recorded.
4. Use CM only for verified completion.
5. Use RV only when the artifact exists but approval evidence is still pending.
6. Use IP when partial artifacts exist.
7. Use NS when no verified artifact exists.
8. Never count legacy or uncertified runtime work as certified Kids completion.