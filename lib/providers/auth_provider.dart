import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../core/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String mobileNumber, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('🔑 [LOGIN ATTEMPT] Mobile: $mobileNumber');

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        {
          'mobile_number': mobileNumber,
          'password': password,
        },
      );

      if (response is Map && response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['token'];
        final driverId = data['id'];

        if (token != null) {
          await _storageService.saveToken(token.toString());
        }
        if (driverId != null) {
          await _storageService.saveDriverId(driverId.toString());
        }

        _isAuthenticated = true;
        _isLoading = false;
        debugPrint('✅ [LOGIN SUCCESS] Driver ID: $driverId');
        notifyListeners();
        return true;
      } else {
        _errorMessage = (response is Map ? response['message'] : null) ?? 'Login failed';
        _isLoading = false;
        debugPrint('❌ [LOGIN FAILED] Reason: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e, stack) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      debugPrint('💥 [LOGIN EXCEPTION] Error: $_errorMessage\nStack: $stack');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout, {});
    } catch (_) {}
    await _storageService.clearAll();
    _isAuthenticated = false;
    notifyListeners();
  }
}
