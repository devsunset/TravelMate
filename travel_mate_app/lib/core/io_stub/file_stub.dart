/// 웹 빌드용 File 스텁. dart:io가 없을 때 사용. 실제 파일 I/O는 불가.
class File {
  File(String path) : _path = path;
  final String _path;
  String get path => _path;
  String get absolutePath => _path;
  File get absolute => this;
}
