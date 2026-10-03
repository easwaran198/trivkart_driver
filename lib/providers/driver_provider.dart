import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/driver_model.dart';
import '../models/notification_model.dart';

class DriverProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  DriverModel? _driver;
  NotificationsModel? _notifications;
  bool _isLoading = false;
  String? _error;

  DriverModel? get driver => _driver;
  NotificationsModel? get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _driver?.isOnline ?? false;

  Future<void> fetchUserInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.userInfo);
      if (response['success'] == true && response['data'] != null) {
        _driver = DriverModel.fromJson(response['data']);
        _error = null;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAvailability(bool targetOnline) async {
    final statusStr = targetOnline ? 'online' : 'offline';
    try {
      final response = await _apiClient.post(
        ApiConstants.updateAvailability,
        {'availability': statusStr},
      );
      if (response['success'] == true) {
        if (_driver != null) {
          _driver = _driver!.copyWith(availability: statusStr);
        } else {
          await fetchUserInfo();
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
    return false;
  }

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _apiClient.post(
        ApiConstants.updateLocation,
        {
          'latitude': lat.toString(),
          'longitude': lng.toString(),
        },
      );
    } catch (_) {}
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await _apiClient.get(ApiConstants.notifications);
      if (response['success'] == true && response['data'] != null) {
        _notifications = NotificationsModel.fromJson(response['data']);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _apiClient.post(
        ApiConstants.notifications,
        {'notification_id': notificationId},
      );
      await fetchNotifications();
    } catch (_) {}
  }
}
