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
    required this.licenseNo,
    required this.photo,
    required this.availability,
    this.vehicle,
    this.rating = 4.8,
  });

  bool get isOnline => availability.toLowerCase() == 'online';

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
      mobile: json['mobile'] ?? json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      licenseNo: json['license_no'] ?? '',
      photo: json['photo'] ?? '',
      availability: json['availability'] ?? 'offline',
      vehicle: json['vehicle'] != null && json['vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['vehicle'])
          : null,
      rating: 4.8,
    );
  }

  DriverModel copyWith({
    String? availability,
    VehicleModel? vehicle,
  }) {
    return DriverModel(
      id: id,
      name: name,
      mobile: mobile,
      email: email,
      licenseNo: licenseNo,
      photo: photo,
      availability: availability ?? this.availability,
      vehicle: vehicle ?? this.vehicle,
      rating: rating,
    );
  }
}
