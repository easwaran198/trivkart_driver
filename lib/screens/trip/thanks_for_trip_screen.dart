import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/driver_main_screen.dart';

class ThanksForTripScreen extends StatelessWidget {
  final String tripId;
  final double fare;
  final Map<String, dynamic>? billData;
  final String? localStopImagePath;

  const ThanksForTripScreen({
    super.key,
    required this.tripId,
    this.fare = 0.0,
    this.billData,
    this.localStopImagePath,
  });

  void _navigateToHome(BuildContext context) {
    // Refresh live driver dashboard & state
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    driverProvider.fetchDashboardDetails();
    driverProvider.fetchUserInfo();
    rideProvider.fetchActiveRide();
    rideProvider.fetchEarnings();
    rideProvider.fetchMyBookings(3);
    rideProvider.fetchMyBookings(2);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DriverMainScreen()),
      (route) => false,
    );
  }

  String _formatImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final url = rawUrl.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return 'https://ttbilling.in/taxibooking/admin-panel$url';
    }
    return 'https://ttbilling.in/taxibooking/admin-panel/$url';
  }

  void _showFullImageDialog(BuildContext context, String title, String imagePathOrUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                color: Colors.black,
                child: _buildImageWidget(imagePathOrUrl, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String pathOrUrl, {BoxFit fit = BoxFit.cover}) {
    final trimmed = pathOrUrl.trim();
    if (trimmed.isEmpty) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 30));
    }

    // Check if it's a local file path that exists
    if (trimmed.startsWith('/') && !trimmed.startsWith('/uploads') && File(trimmed).existsSync()) {
      return Image.file(
        File(trimmed),
        fit: fit,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 30)),
      );
    }

    // Otherwise format as full network URL
    final fullUrl = _formatImageUrl(trimmed);
    return Image.network(
      fullUrl,
      fit: fit,
      headers: const {'Accept': 'image/*'},
      errorBuilder: (context, error, stackTrace) {
        // If network image failed and we have local stop image fallback
        if (localStopImagePath != null && localStopImagePath!.isNotEmpty && File(localStopImagePath!).existsSync()) {
          return Image.file(
            File(localStopImagePath!),
            fit: fit,
          );
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
              SizedBox(height: 4),
              Text('Image not available', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = billData?['data'] is Map<String, dynamic>
        ? billData!['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final bookingId = data['booking_id']?.toString() ?? billData?['booking_id']?.toString() ?? tripId;
    final tripIdCode = data['trip_id']?.toString() ?? billData?['trip_id']?.toString() ?? 'TRIP$bookingId';
    
    final finalFare = billData?['fare'] ?? billData?['price'] ?? data['fare'] ?? fare;
    final fareNum = finalFare is num ? finalFare.toDouble() : double.tryParse(finalFare.toString()) ?? fare;
    
    final currencySymbol = billData?['currency'] == 'INR' ? '₹' : (billData?['currency'] ?? '₹');
    final totalKm = billData?['total_km'] ?? billData?['total_distance_km'] ?? billData?['distance_km'] ?? data['total_km'] ?? 0;
    final ratePerKm = billData?['rate_per_km'] ?? data['rate_per_km'] ?? 0;
    final fareFormula = billData?['fare_formula']?.toString() ?? data['fare_formula']?.toString() ?? '';

    final startOdometer = data['start_odometer'] ?? billData?['start_odometer'] ?? '--';
    final stopOdometer = data['stop_odometer'] ?? data['odometer_value'] ?? billData?['stop_odometer'] ?? '--';

    // Start photo path
    String startPhotoUrl = (data['start_odometer_photo'] ?? billData?['start_odometer_photo'] ?? '').toString();

    // Stop photo path (with fallback to local camera image if needed)
    String stopPhotoUrl = (data['stop_odometer_photo'] ?? data['odometer_photo'] ?? billData?['stop_odometer_photo'] ?? billData?['odometer_photo'] ?? '').toString();
    if (stopPhotoUrl.isEmpty && localStopImagePath != null && localStopImagePath!.isNotEmpty) {
      stopPhotoUrl = localStopImagePath!;
    }

    final hasPhotos = startPhotoUrl.trim().isNotEmpty || stopPhotoUrl.trim().isNotEmpty;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + topPadding),
        child: Container(
          color: const Color(0xFF1E3A8A),
          padding: EdgeInsets.only(top: topPadding),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                const Text(
                  'Trip Bill Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _navigateToHome(context),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Celebratory Success Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 48),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Thanks for the Trip!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ride has been completed & odometer recorded.',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'TX#$bookingId • $tripIdCode',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Bill Amount & Formula Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Fare Amount',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$currencySymbol ${fareNum.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          if (fareFormula.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.onlineGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.onlineGreen.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calculate_outlined, size: 16, color: AppTheme.onlineGreen),
                                  const SizedBox(width: 6),
                                  Text(
                                    fareFormula,
                                    style: const TextStyle(
                                      color: AppTheme.onlineGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Odometer & Distance Calculation Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.speed, color: AppTheme.primaryBlue, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Odometer & Trip Details',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoTile('Start Reading', '$startOdometer km', Icons.play_circle_outline, Colors.blue),
                              _buildInfoTile('Stop Reading', '$stopOdometer km', Icons.stop_circle_outlined, Colors.purple),
                              _buildInfoTile('Total Distance', '$totalKm km', Icons.route, AppTheme.onlineGreen),
                            ],
                          ),
                          if (ratePerKm > 0) ...[
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Rate per KM',
                                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                ),
                                Text(
                                  '$currencySymbol $ratePerKm / km',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Odometer Photos Card (Always show section if photos exist)
                    if (hasPhotos)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.photo_camera_outlined, color: AppTheme.primaryBlue, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Odometer Proofs (Click to zoom)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (startPhotoUrl.isNotEmpty)
                                  Expanded(
                                    child: _buildPhotoThumbnail(
                                      context,
                                      'Start Odometer',
                                      startPhotoUrl,
                                    ),
                                  ),
                                if (startPhotoUrl.isNotEmpty && stopPhotoUrl.isNotEmpty)
                                  const SizedBox(width: 12),
                                if (stopPhotoUrl.isNotEmpty)
                                  Expanded(
                                    child: _buildPhotoThumbnail(
                                      context,
                                      'Stop Odometer',
                                      stopPhotoUrl,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Button (Close & Go to Home)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.onlineGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _navigateToHome(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Close & Go to Home',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, String label, String imagePathOrUrl) {
    return GestureDetector(
      onTap: () => _showFullImageDialog(context, label, imagePathOrUrl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 110,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWidget(imagePathOrUrl, fit: BoxFit.cover),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
