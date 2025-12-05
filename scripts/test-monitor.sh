#!/usr/bin/env bash
set -euo pipefail

PROCESS_NAME="test"
URL="https://test.com/monitoring/test/api"
STATE_FILE="/var/run/test-monitor.pid"
LOG_FILE="/var/log/monitoring.log"

now() {
  date "+%Y-%m-%d %H:%M:%S"
}

mkdir -p "$(dirname "$STATE_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Поиск процесса
PID=$(pgrep -xo "$PROCESS_NAME" || true)

# Если процесса нет — ничего не делаем
if [[ -z "$PID" ]]; then
  exit 0
fi

# Проверка изменения PID
OLD_PID=""
if [[ -f "$STATE_FILE" ]]; then
  OLD_PID=$(cat "$STATE_FILE" || true)
fi

if [[ -n "$OLD_PID" && "$OLD_PID" != "$PID" ]]; then
  echo "$(now) Процесс '$PROCESS_NAME' был перезапущен: старый PID=$OLD_PID, новый PID=$PID" >> "$LOG_FILE"
fi

echo "$PID" > "$STATE_FILE"

# Проверка доступности мониторинга
if ! curl -fsS --max-time 5 "$URL" >/dev/null 2>&1; then
  echo "$(now) Сервер мониторинга недоступен для процесса '$PROCESS_NAME' (PID=$PID)" >> "$LOG_FILE"
fi