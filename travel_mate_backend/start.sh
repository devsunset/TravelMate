#!/bin/bash
# TravelMate 백엔드 서버 기동
# 사용법: ./start.sh

cd "$(dirname "$0")"
PID_FILE=".server.pid"
LOG_FILE="logs/server.log"

# 이미 실행 중이면 기동하지 않음
if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE")
  if kill -0 "$OLD_PID" 2>/dev/null; then
    echo "이미 서버가 실행 중입니다. (PID: $OLD_PID)"
    exit 1
  fi
  rm -f "$PID_FILE"
fi

# 로그 디렉터리 생성
mkdir -p logs

# 백그라운드로 서버 실행, PID 저장
nohup node src/app.js >> "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
echo "서버를 시작했습니다. (PID: $(cat "$PID_FILE"))"
echo "로그: $LOG_FILE"
