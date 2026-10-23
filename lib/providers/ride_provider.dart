import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/ride_model.dart';
import '../models/earnings_model.dart';

class RideProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<RideModel> _newRequests = [];
  RideModel? _activeRide;
  List<RideModel> _rideHistory = [];
  
  // Categorized My Bookings lists for status 1, 2, 3, 4
  List<RideModel> _newBookings = [];
  List<RideModel> _acceptedBookings = [];
  List<RideModel> _completedBookings = [];
  List<RideModel> _cancelledBookings = [];

  EarningsModel? _earnings;
  bool _isLoading = false;
  String? _error;

  List<RideModel> get newRequests => _newRequests;
  RideModel? get activeRide => _activeRide;
  List<RideModel> get rideHistory => _rideHistory;

  List<RideModel> get newBookings => _newBookings;
  List<RideModel> get acceptedBookings => _acceptedBookings;
  List<RideModel> get completedBookings => _completedBookings;
  List<RideModel> get cancelledBookings => _cancelledBookings;

  EarningsModel? get earnings => _earnings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNewRequests() async {
    try {
      final response = await _apiClient.get(ApiConstants.newRequests);
      if (response['success'] == true && response['data'] is List) {
        final rawList = response['data'] as List;
        _newRequests = rawList.map((e) => RideModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> fetchMyBookings(int status, {int page = 1, int limit = 20}) async {
    _isLoading = true;
    notifyListeners();

    final url = '${ApiConstants.myBooking}?status=$status&limit=$limit&page=$page';
    try {
      final response = await _apiClient.get(url);
      if (response['success'] == true && response['data'] is List) {
        final rawList = response['data'] as List;
        final list = rawList.map((e) => RideModel.fromJson(e)).toList();
        
        if (status == 1) {
          _newBookings = list;
        } else if (status == 2) {
          _acceptedBookings = list;
        } else if (status == 3) {
          _completedBookings = list;
        } else if (status == 4) {
          _cancelledBookings = list;
        }
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptRide(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.acceptRide,
        {'booking_id': bookingId},
      );
      if (response['success'] == true) {
        _newRequests.removeWhere((r) => r.bookingId == bookingId);
        await fetchActiveRide();
        await fetchMyBookings(1);
        await fetchMyBookings(2);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> cancelRide(String bookingId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.cancelRide,
        {
          'booking_id': bookingId,
          'reason': reason,
        },
      );

      if (response['success'] == true) {
        _newRequests.removeWhere((r) => r.bookingId == bookingId);
        _newBookings.removeWhere((r) => r.bookingId == bookingId);
        _acceptedBookings.removeWhere((r) => r.bookingId == bookingId);

        // Refresh all relevant My Bookings tabs (1: New, 2: Accepted, 4: Cancelled)
        await fetchMyBookings(1);
        await fetchMyBookings(2);
        await fetchMyBookings(4);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to cancel ride';
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> declineRide(String bookingId) async {
    return cancelRide(bookingId, 'Declined by driver');
  }

  Future<void> fetchActiveRide() async {
    try {
      final response = await _apiClient.get(ApiConstants.activeRide);
      if (response['success'] == true && response['data'] != null) {
        if (response['data'] is Map<String, dynamic>) {
          _activeRide = RideModel.fromJson(response['data']);
        }
      } else {
        _activeRide = null;
      }
      notifyListeners();
    } catch (_) {
      _activeRide = null;
    }
  }

  Future<bool> startRide(
    String bookingId, {
    required String otp,
    required String odometerValue,
    required String odometerPhotoPath,
    String status = 'start',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fields = <String, String>{
        'booking_id': bookingId,
        'status': status,
        'otp': otp,
        'odometer_value': odometerValue,
      };

      final files = <String, String>{
        'odometer_photo': odometerPhotoPath,
      };

      final response = await _apiClient.postMultipart(
        ApiConstants.startRide,
        fields,
        files,
      );

      if (response['success'] == true || response['status'] == true) {
        await fetchActiveRide();
        await fetchMyBookings(2);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to start ride';
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<Map<String, dynamic>?> stopRide(
    String bookingId, {
    String otp = '',
    required String odometerValue,
    required String odometerPhotoPath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fields = <String, String>{
        'booking_id': bookingId,
        'status': 'stop',
        'odometer_value': odometerValue,
      };

      if (otp.isNotEmpty) {
        fields['otp'] = otp;
      }

      final files = <String, String>{
        'odometer_photo': odometerPhotoPath,
      };

      final response = await _apiClient.postMultipart(
        ApiConstants.startRide,
        fields,
        files,
      );

      if (response['success'] == true || response['status'] == true) {
        _activeRide = null;
        await fetchActiveRide();
        await fetchEarnings();
        await fetchMyBookings(3);
        await fetchMyBookings(2);
        _isLoading = false;
        notifyListeners();
        return response;
      } else {
        _error = response['message'] ?? 'Failed to complete ride';
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> completeRide(String bookingId, double fare) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.completeRide,
        {
          'booking_id': bookingId,
          'fare': fare.toStringAsFixed(2),
        },
      );
      if (response['success'] == true) {
        _activeRide = null;
        await fetchEarnings();
        await fetchMyBookings(3);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> fetchRideHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.rideHistory);
      if (response['success'] == true && response['data'] is List) {
        final rawList = response['data'] as List;
        _rideHistory = rawList.map((e) => RideModel.fromJson(e)).toList();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEarnings() async {
    try {
      final response = await _apiClient.get(ApiConstants.earnings);
      if (response['success'] == true && response['data'] != null) {
        _earnings = EarningsModel.fromJson(response['data']);
        notifyListeners();
      }
    } catch (_) {}
  }
}
