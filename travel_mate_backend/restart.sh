#!/bin/bash
# TravelMate 백엔드 서버 재시작 (종료 후 기동)
# 사용법: ./restart.sh

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

echo "서버 재시작 중..."
"$SCRIPT_DIR/stop.sh"
sleep 2
"$SCRIPT_DIR/start.sh"
