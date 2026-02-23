import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart' as quill_delta;

/// Quill Delta JSON 문자열 또는 일반 텍스트를 [quill.Document]로 변환.
quill.Document quillDocumentFromContent(String content) {
  if (content.trim().isEmpty) {
    return quill.Document();
  }
  try {
    final s = content.trim();
    if (s.startsWith('[')) {
      final list = jsonDecode(content) as List;
      return quill.Document.fromDelta(quill_delta.Delta.fromJson(list));
    }
  } catch (_) {}
  return quill.Document.fromDelta(quill_delta.Delta()..insert(content));
}

/// [quill.Document]를 백엔드 저장용 JSON 문자열로 직렬화.
String quillContentFromDocument(quill.Document document) {
  return jsonEncode(document.toDelta().toJson());
}

/// content가 Quill Delta JSON 형식인지 여부.
bool isQuillDeltaContent(String content) {
  final s = content.trim();
  return s.startsWith('[') && (s.endsWith(']') || s.length > 1);
}
