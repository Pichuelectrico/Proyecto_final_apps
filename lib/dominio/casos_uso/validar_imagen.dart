import 'dart:io';

class ValidarImagen {
  static const int maxBytes = 15 * 1024 * 1024;

  Future<bool> ejecutar(String localPath) async {
    if (localPath.trim().isEmpty) return false;
    final file = File(localPath);
    if (!await file.exists()) return false;
    final length = await file.length();
    if (length <= 0 || length > maxBytes) return false;
    return true;
  }
}
