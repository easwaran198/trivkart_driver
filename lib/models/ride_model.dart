class CustomerModel {
  final String name;
  final String mobile;
  final String? email;

  CustomerModel({
    required this.name,
    required this.mobile,
    this.email,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      name: json['name'] ?? json['customer_name'] ?? '',
      mobile: json['mobile'] ?? json['customer_mobile'] ?? '',
      email: json['email'],
    );
  }
}

class RideModel {
  final String tripId;
  final String bookingId;
  final String pickupLocation;
  final String dropLocation;
  final String tripType;
  final String startDate;
  final String pickupTime;
  final int noOfPassengers;
  final double distanceKm;
  final double fare;
  final String status;
  final String statusText;
  final String offerStatus;
  final String paymentStatus;
  final String paymentMode;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final CustomerModel customer;
  final String pickupOtp;
  final String adminApproval;
  final String cancellationReason;
  final String createdAt;

  bool get isAdminApproved => adminApproval.trim().toLowerCase() == 'approved';

  RideModel({
    required this.tripId,
    required this.bookingId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.tripType,
    required this.startDate,
    required this.pickupTime,
    required this.noOfPassengers,
    required this.distanceKm,
    required this.fare,
    required this.status,
    required this.statusText,
    this.offerStatus = '',
    required this.paymentStatus,
    this.paymentMode = 'Cash',
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    required this.customer,
    this.pickupOtp = '',
    this.adminApproval = '',
    this.cancellationReason = '',
    required this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      tripId: json['trip_id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      pickupLocation: (json['pickup'] != null && json['pickup'].toString().isNotEmpty)
          ? json['pickup'].toString()
          : (json['pickup_location']?.toString() ?? ''),
      dropLocation: (json['drop'] != null && json['drop'].toString().isNotEmpty)
          ? json['drop'].toString()
          : (json['drop_location']?.toString() ?? ''),
      tripType: json['trip_type'] ?? 'one_way',
      startDate: json['start_date'] ?? '',
      pickupTime: json['pickup_time'] ?? '',
      noOfPassengers: json['no_of_passengers'] is int
          ? json['no_of_passengers']
          : int.tryParse(json['no_of_passengers']?.toString() ?? '1') ?? 1,
      distanceKm: (json['distance_km'] is num)
          ? (json['distance_km'] as num).toDouble()
          : double.tryParse(json['distance_km']?.toString() ?? '0.0') ?? 0.0,
      fare: (json['fare'] is num)
          ? (json['fare'] as num).toDouble()
          : double.tryParse(json['fare']?.toString() ?? '0.0') ?? 0.0,
      status: json['status'] ?? json['booking_status'] ?? json['offer_status'] ?? 'pending',
      statusText: json['status_text'] ?? json['status'] ?? 'Pending',
      offerStatus: json['offer_status'] ?? '',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paymentMode: json['payment_mode'] ?? 'Cash',
      pickupLat: double.tryParse(json['pickup_latitude']?.toString() ?? ''),
      pickupLng: double.tryParse(json['pickup_longitude']?.toString() ?? ''),
      dropLat: double.tryParse(json['drop_latitude']?.toString() ?? ''),
      dropLng: double.tryParse(json['drop_longitude']?.toString() ?? ''),
      customer: json['customer'] != null && json['customer'] is Map<String, dynamic>
          ? CustomerModel.fromJson(json['customer'])
          : CustomerModel(
              name: json['customer_name'] ?? 'Customer',
              mobile: json['customer_mobile'] ?? '',
            ),
      pickupOtp: json['pickup_otp'] ?? '',
      adminApproval: json['admin_approval']?.toString() ?? '',
      cancellationReason: json['cancellation_reason'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
