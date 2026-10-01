import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String hash(String password) {
    final salt = _newSalt();
    return '$salt:${_digest(password, salt)}';
  }

  static bool verify(String password, String stored) {
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    return _digest(password, parts[0]) == parts[1];
  }

  static String _newSalt() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  static String _digest(String password, String salt) {
    List<int> bytes = utf8.encode('$salt$password');
    for (var i = 0; i < 1000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64UrlEncode(bytes);
  }
}