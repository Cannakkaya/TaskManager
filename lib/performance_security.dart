// Örnek: Şifrelenmiş Depolama
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:task_manager/main.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _encryptionKey = 'task_manager_encryption_key';

  Future<void> saveEncryptedTasks(List<Task> tasks) async {
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    final encryptedData = _encrypt(tasksJson);
    await _secureStorage.write(key: 'encrypted_tasks', value: encryptedData);
  }

  Future<List<Task>> loadEncryptedTasks() async {
    final encryptedData = await _secureStorage.read(key: 'encrypted_tasks');
    if (encryptedData == null) return [];

    final tasksJson = _decrypt(encryptedData);
    final List<dynamic> decodedTasks = jsonDecode(tasksJson);
    return decodedTasks.map((task) => Task.fromJson(task)).toList();
  }

  String _encrypt(String data) {
    // Basit şifreleme örneği (gerçek uygulamada daha güvenli bir yöntem kullanılmalı)
    final key = utf8.encode(_encryptionKey);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return base64.encode(bytes) + '.' + digest.toString();
  }

  String _decrypt(String encryptedData) {
    // Basit şifre çözme örneği
    final parts = encryptedData.split('.');
    final data = parts[0];

    return utf8.decode(base64.decode(data));
  }
}
