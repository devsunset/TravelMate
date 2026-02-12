#!/bin/bash
# TravelMate 백엔드 서버 종료
# 사용법: ./stop.sh

cd "$(dirname "$0")"
PID_FILE=".server.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "실행 중인 서버가 없습니다. (PID 파일 없음)"
  exit 0
fi

PID=$(cat "$PID_FILE")
if kill -0 "$PID" 2>/dev/null; then
  kill "$PID"
  echo "서버를 종료했습니다. (PID: $PID)"
else
  echo "프로세스가 이미 종료되었습니다. (PID: $PID)"
fi
rm -f "$PID_FILE"
