import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyDriverId = 'driver_id';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveDriverId(String driverId) async {
    await _storage.write(key: _keyDriverId, value: driverId);
  }

  Future<String?> getDriverId() async {
    return await _storage.read(key: _keyDriverId);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
