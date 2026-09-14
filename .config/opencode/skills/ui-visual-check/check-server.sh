#!/usr/bin/env bash
# check-server.sh — attende che un dev server HTTP risponda 2xx/3xx.
# Uso: bash check-server.sh <url> [timeout_sec]
# Esempio: bash check-server.sh http://localhost:5173 30
set -u

URL="${1:?Usage: $0 <url> [timeout_sec]}"
TIMEOUT_SEC="${2:-30}"

deadline=$(( $(date +%s) + TIMEOUT_SEC ))

while [ "$(date +%s)" -lt "$deadline" ]; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null || true)
  if [[ "$code" =~ ^[23] ]]; then
    echo "UP $code"
    exit 0
  fi
  sleep 1
done

echo "DOWN dopo $TIMEOUT_SEC s"
exit 1
