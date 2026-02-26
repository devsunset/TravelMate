# TravelMate — 프로젝트 규칙 요약

AI 어시스턴트(Cursor 등)와 팀이 공통으로 참고하는 규칙입니다.

## Cursor 규칙 위치
- **루트**: `.cursorrules` — 요약 및 규칙 파일 위치 안내
- **상세**: `.cursor/rules/` 아래 `.mdc` 파일
  - `project-overview.mdc` — 항상 적용 (프로젝트 구조, 공통 규칙)
  - `flutter-dart.mdc` — Flutter/Dart 파일 편집 시
  - `backend-node.mdc` — 백엔드 JS 파일 편집 시

## 핵심 규칙
1. **응답**: 한국어 코드/주석·한국어 사용자면 한국어로 답변.
2. **구조**: 앱은 presentation / domain / data 레이어, 백엔드는 routes / controllers / models.
3. **인증**: 백엔드 API는 Bearer 토큰 필수; 사용자 식별은 백엔드 랜덤 ID, 이메일 미수집.
4. **플랫폼**: 앱 웹 빌드 시 `dart:io` 미사용 — 조건부 export로 웹/IO 분리.
5. **문서**: API·DB 변경 시 `doc/`, `README.md` 등 문서 반영.

더 세부 규칙은 `.cursor/rules/` 내 각 `.mdc`를 참고하세요.
