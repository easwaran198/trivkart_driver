import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/driver_model.dart';
import '../models/notification_model.dart';

class DriverProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  DriverModel? _driver;
  DriverProfileModel? _profile;
  DashboardDetailsModel? _dashboardDetails;
  NotificationsModel? _notifications;
  bool _isLoading = false;
  String? _error;

  DriverModel? get driver => _driver;
  DriverProfileModel? get profile => _profile;
  DashboardDetailsModel? get dashboardDetails => _dashboardDetails;
  NotificationsModel? get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _driver?.isOnline ?? false;

  Future<void> fetchDashboardDetails() async {
    try {
      final response = await _apiClient.get(ApiConstants.dashboardDetails);
      if ((response['status'] == true || response['success'] == true) && response['data'] != null) {
        if (response['data'] is Map<String, dynamic>) {
          _dashboardDetails = DashboardDetailsModel.fromJson(response['data']);
          notifyListeners();
        }
      } else if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        _dashboardDetails = DashboardDetailsModel.fromJson(response['data']);
        notifyListeners();
      } else if (response is Map<String, dynamic> && (response.containsKey('total_earnings') || response.containsKey('today_earnings') || response.containsKey('total_bookings') || response.containsKey('total'))) {
        _dashboardDetails = DashboardDetailsModel.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ [DASHBOARD DETAILS ERROR] $e');
    }
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.viewProfile);
      if ((response['status'] == true || response['success'] == true) && response['data'] != null) {
        if (response['data'] is Map<String, dynamic>) {
          _profile = DriverProfileModel.fromJson(response['data']);
          _driver = DriverModel.fromJson(response['data']);
          _error = null;
        }
      } else if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        _profile = DriverProfileModel.fromJson(response['data']);
        _driver = DriverModel.fromJson(response['data']);
        _error = null;
      } else if (response is Map<String, dynamic> && (response.containsKey('name') || response.containsKey('email'))) {
        _profile = DriverProfileModel.fromJson(response);
        _driver = DriverModel.fromJson(response);
        _error = null;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('⚠️ [VIEW PROFILE ERROR] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editProfile({
    required String name,
    required String email,
    required String mobileNumber,
    required String address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        'name': name.trim(),
        'email': email.trim(),
        'mobile_number': mobileNumber.trim(),
        'address': address.trim(),
      };

      final response = await _apiClient.post(ApiConstants.editProfile, payload);
      if (response['status'] == true || response['success'] == true) {
        await fetchProfile();
        return true;
      } else {
        _error = response['message']?.toString() ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('⚠️ [EDIT PROFILE ERROR] $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.userInfo);
      if (response['success'] == true && response['data'] != null) {
        _driver = DriverModel.fromJson(response['data']);
        _profile = DriverProfileModel.fromJson(response['data']);
        _error = null;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    await fetchDashboardDetails();
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
