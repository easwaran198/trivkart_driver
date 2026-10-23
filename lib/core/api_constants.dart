class ApiConstants {
  static const String baseUrl = 'https://ttbilling.in/taxibooking/admin-panel/api/driver';

  // Endpoints
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String userInfo = '$baseUrl/user-info';
  static const String updateAvailability = '$baseUrl/update-availability';
  static const String updateLocation = '$baseUrl/update-location';
  static const String newRequests = '$baseUrl/new-requests';
  static const String acceptRide = '$baseUrl/accept-ride';
  static const String declineRide = '$baseUrl/decline-ride';
  static const String cancelRide = '$baseUrl/cancel-ride';
  static const String activeRide = '$baseUrl/active-ride';
  static const String startRide = '$baseUrl/start-ride';
  static const String completeRide = '$baseUrl/complete-ride';
  static const String rideDetails = '$baseUrl/ride-details';
  static const String rideHistory = '$baseUrl/ride-history';
  static const String myBooking = '$baseUrl/my_booking';
  static const String earnings = '$baseUrl/earnings';
  static const String dashboardDetails = '$baseUrl/dashboard-details';
  static const String notifications = '$baseUrl/notifications';
  static const String viewProfile = '$baseUrl/view_profile';
  static const String editProfile = '$baseUrl/edit_profile';
}
