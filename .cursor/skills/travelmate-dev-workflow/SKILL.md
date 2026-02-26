---
name: travelmate-dev-workflow
description: Enforces TravelMate development workflow across Flutter app and Node backend: prevents Flutter web dart:io/_Namespace issues, standardizes API query/result logging, and guides safe commit/push when git trailer option breaks. Use when fixing cross-platform bugs, adding upload/search endpoints, adding debug logs, or when the user asks to commit/push.
---

# TravelMate Dev Workflow

## Quick start (always follow in this order)
1. **Identify runtime target**: Web vs Mobile/IO vs Backend.
2. **Pick the right layer**:
   - Flutter UI: `presentation/`
   - Flutter domain: `domain/`
   - Flutter data/API: `data/`
   - Backend routing/controller/model: `travel_mate_backend/src/`
3. **Add logs only in safe places**:
   - Flutter: `kDebugMode` + `debugPrint`
   - Backend: `console.log`/`console.error`
   - Never log tokens / PII.
4. **Validate**:
   - Flutter: `flutter analyze`
   - Backend: start server + hit endpoint once (curl or app)

## A) Flutter Web `_Namespace` / `dart:io` 방지 체크리스트

### Symptoms
- Error: `Unsupported operation: _Namespace`
- Usually caused by **web build loading code that imports/uses `dart:io`**.

### Fix pattern
- **Never** use `dart:io` (`File`, `Directory`, `Platform`) in web code paths.
- Prefer `XFile` (from `image_picker`) and `readAsBytes()` for web upload.

### Mandatory rules
- **Conditional export/import must select web implementation on web**.
  - Pattern to use:
    - `export 'impl_io.dart' if (dart.library.html) 'impl_web.dart';`
  - Verify by grepping for the conditional file and ensuring the web file is the conditional target.
- If a repository/usecase passes “image”:
  - Use `dynamic image` and accept:
    - Mobile/IO: `String path` or `XFile.path`
    - Web: `XFile` → bytes

### Minimal test
- Run:
  - `flutter build web`
- Ensure profile save/upload path does not throw `_Namespace`.

## B) 동행찾기(검색/필터) “실제 쿼리·결과 로그” 표준

### Client (Flutter, Dio)
- Log request query parameters and response summary in `kDebugMode`.
- Format:
  - `[동행 검색] 요청 쿼리: {...}`
  - `[동행 검색] 응답: total=..., returned=..., limit=..., offset=...`

### Server (Express/Sequelize)
- Log (no tokens):
  - `[동행 검색] 수신 쿼리: {...}`
  - `[동행 검색] 질의 조건: { userWhere, profileWhere, ... }`
  - `[동행 검색] 질의 결과: { total, returned, sampleNicknames }`

### Never do
- Don’t log `Authorization` headers / Firebase ID token.

## C) Commit / Push 워크플로우 (git trailer 이슈 포함)

### Symptom
- `git commit` fails with: `error: unknown option 'trailer'`
  - Trace shows: `git commit --trailer 'Made-with: Cursor' ...`

### Fix (preferred)
- Use system git binary directly:
  - `/usr/bin/git commit -m \"...\"`
  - `/usr/bin/git push origin <branch>`

### Safety rules
- Don’t rewrite history unless user explicitly asks.
- Don’t force push to `master/main`.

