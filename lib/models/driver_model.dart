import 'ride_model.dart';

class VehicleModel {
  final int id;
  final String model;
  final String plateNo;
  final String type;
  final int capacity;
  final String status;

  VehicleModel({
    required this.id,
    required this.model,
    required this.plateNo,
    required this.type,
    required this.capacity,
    required this.status,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      model: json['model'] ?? '',
      plateNo: json['plate_no'] ?? json['plateNo'] ?? '',
      type: json['type'] ?? 'Sedan',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity'].toString()) ?? 4,
      status: json['status'] ?? 'available',
    );
  }
}

class DriverModel {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String licenseNo;
  final String photo;
  final String availability;
  final VehicleModel? vehicle;
  final double rating;

  DriverModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    this.address = '',
    required this.licenseNo,
    required this.photo,
    required this.availability,
    this.vehicle,
    this.rating = 4.8,
  });

  bool get isOnline => availability.toLowerCase() == 'online';

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id']?.toString() ?? json['driver_id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? json['driver_name'] ?? '',
      mobile: json['mobile'] ?? json['mobileNumber'] ?? json['mobile_number'] ?? json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      licenseNo: json['license_no'] ?? json['license_number'] ?? '',
      photo: json['photo'] ?? json['profile_image'] ?? json['image'] ?? '',
      availability: json['availability'] ?? json['status'] ?? 'offline',
      vehicle: json['vehicle'] != null && json['vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['vehicle'])
          : null,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
    );
  }

  DriverModel copyWith({
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? availability,
    VehicleModel? vehicle,
  }) {
    return DriverModel(
      id: id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      licenseNo: licenseNo,
      photo: photo,
      availability: availability ?? this.availability,
      vehicle: vehicle ?? this.vehicle,
      rating: rating,
    );
  }
}

class DriverProfileModel {
  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String licenseNumber;
  final String photo;
  final String availability;
  final String gender;
  final String dob;
  final String experience;
  final double rating;
  final VehicleModel? vehicle;
  final Map<String, dynamic> rawData;

  DriverProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.address,
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.licenseNumber = '',
    this.photo = '',
    this.availability = 'offline',
    this.gender = '',
    this.dob = '',
    this.experience = '',
    this.rating = 4.8,
    this.vehicle,
    this.rawData = const {},
  });

  bool get isOnline => availability.toLowerCase() == 'online';

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id']?.toString() ?? json['driver_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['driver_name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? json['pin_code']?.toString() ?? json['zip']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? json['license_no']?.toString() ?? json['driving_license']?.toString() ?? '',
      photo: json['photo']?.toString() ?? json['profile_image']?.toString() ?? json['image']?.toString() ?? '',
      availability: json['availability']?.toString() ?? json['status']?.toString() ?? 'offline',
      gender: json['gender']?.toString() ?? '',
      dob: json['dob']?.toString() ?? json['date_of_birth']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      vehicle: json['vehicle'] != null && json['vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['vehicle'])
          : null,
      rawData: json,
    );
  }
}

class DashboardDetailsModel {
  final String availability;
  final int newRequests;
  final int accepted;
  final int completed;
  final int cancelled;
  final int totalBookings;
  final RideModel? activeRide;
  final double todayEarnings;
  final int todayRides;
  final double monthEarnings;
  final int monthRides;
  final double totalEarnings;
  final int totalRides;
  final Map<String, dynamic> rawData;

  DashboardDetailsModel({
    this.availability = 'offline',
    this.newRequests = 0,
    this.accepted = 0,
    this.completed = 0,
    this.cancelled = 0,
    this.totalBookings = 0,
    this.activeRide,
    this.todayEarnings = 0.0,
    this.todayRides = 0,
    this.monthEarnings = 0.0,
    this.monthRides = 0,
    this.totalEarnings = 0.0,
    this.totalRides = 0,
    this.rawData = const {},
  });

  // Backward compatibility getters
  int get totalTripCount => totalRides > 0 ? totalRides : totalBookings;
  int get completedTripCount => completed;
  int get cancelledTripCount => cancelled;
  String? get currentBookingId => activeRide?.bookingId;

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(',', '').trim()) ?? 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString().replaceAll(',', '').trim()) ?? 0;
  }

  factory DashboardDetailsModel.fromJson(Map<String, dynamic> json) {
    RideModel? active;
    if (json['active_ride'] != null && json['active_ride'] is Map<String, dynamic>) {
      active = RideModel.fromJson(json['active_ride']);
    }

    final todayMap = json['today'] is Map<String, dynamic> ? (json['today'] as Map<String, dynamic>) : null;
    final monthMap = json['month'] is Map<String, dynamic> ? (json['month'] as Map<String, dynamic>) : null;
    final totalMap = json['total'] is Map<String, dynamic> ? (json['total'] as Map<String, dynamic>) : null;

    final double rawTodayAmt = _parseDouble(
      todayMap?['amount'] ??
      todayMap?['earnings'] ??
      todayMap?['total'] ??
      json['today_earnings'] ??
      json['todayEarnings'] ??
      json['today_earning'] ??
      json['todays_earnings'] ??
      json['today_income'],
    );

    final double rawMonthAmt = _parseDouble(
      monthMap?['amount'] ??
      monthMap?['earnings'] ??
      monthMap?['total'] ??
      json['month_earnings'] ??
      json['monthEarnings'] ??
      json['monthly_earnings'] ??
      json['month_earning'] ??
      json['month_income'],
    );

    final double rawTotalAmt = _parseDouble(
      totalMap?['amount'] ??
      totalMap?['earnings'] ??
      totalMap?['total'] ??
      json['total_earnings'] ??
      json['totalEarnings'] ??
      json['total_earning'] ??
      json['earnings'] ??
      json['total_income'],
    );

    final int parsedTodayRides = _parseInt(
      todayMap?['rides'] ??
      todayMap?['trips'] ??
      todayMap?['count'] ??
      json['today_rides'] ??
      json['today_trips'] ??
      json['todayTrips'] ??
      json['today_ride_count'],
    );

    final int parsedMonthRides = _parseInt(
      monthMap?['rides'] ??
      monthMap?['trips'] ??
      monthMap?['count'] ??
      json['month_rides'] ??
      json['month_trips'] ??
      json['monthTrips'],
    );

    final int parsedTotalCount = _parseInt(
      json['total_bookings'] ??
      json['total_trip_count'] ??
      json['total_trips'] ??
      json['total_rides'] ??
      json['totalBookings'] ??
      totalMap?['rides'] ??
      totalMap?['trips'],
    );

    final int compCount = _parseInt(
      json['completed'] ??
      json['completed_trip_count'] ??
      json['completed_rides'] ??
      json['completed_bookings'],
    );

    final int cancCount = _parseInt(
      json['cancelled'] ??
      json['cancelled_trip_count'] ??
      json['cancelled_rides'] ??
      json['cancelled_bookings'],
    );

    final int newReqCount = _parseInt(
      json['new_requests'] ??
      json['new_bookings'] ??
      json['pending'],
    );

    final int accCount = _parseInt(
      json['accepted'] ??
      json['accepted_trip_count'] ??
      json['accepted_rides'] ??
      json['accepted_bookings'],
    );

    return DashboardDetailsModel(
      availability: json['availability']?.toString() ?? 'offline',
      newRequests: newReqCount,
      accepted: accCount,
      completed: compCount,
      cancelled: cancCount,
      totalBookings: parsedTotalCount,
      activeRide: active,
      todayEarnings: rawTodayAmt,
      todayRides: parsedTodayRides,
      monthEarnings: rawMonthAmt,
      monthRides: parsedMonthRides,
      totalEarnings: rawTotalAmt,
      totalRides: totalMap != null && totalMap['rides'] != null ? _parseInt(totalMap['rides']) : parsedTotalCount,
      rawData: json,
    );
  }
}

