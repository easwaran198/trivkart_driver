import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride_model.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import 'otp_verification_dialog.dart';
import 'thanks_for_trip_screen.dart';

class TripInProgressScreen extends StatelessWidget {
  final RideModel ride;
  const TripInProgressScreen({super.key, required this.ride});

  void _onDropCustomer(BuildContext context) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const OtpVerificationDialog(isStartTrip: false),
    );

    if (result != null && context.mounted) {
      String? otp;
      String? odometer;
      String? imagePath;

      if (result is StartTripResult) {
        otp = result.otp;
        odometer = result.odometerReading;
        imagePath = result.imagePath;
      }

      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      final stopResult = await rideProvider.stopRide(
        ride.bookingId,
        otp: otp ?? '',
        odometerValue: odometer ?? '',
        odometerPhotoPath: imagePath ?? '',
      );

      if (context.mounted) {
        if (stopResult != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThanksForTripScreen(
                tripId: ride.bookingId.isNotEmpty ? ride.bookingId : ride.tripId,
                fare: ride.fare,
                billData: stopResult,
                localStopImagePath: imagePath,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(rideProvider.error ?? 'Failed to complete trip'),
              backgroundColor: AppTheme.offlineRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripIdDisplay = ride.bookingId.isNotEmpty ? ride.bookingId : ride.tripId;
    final hasCustomerName = ride.customer.name.trim().isNotEmpty;
    final hasCustomerMobile = ride.customer.mobile.trim().isNotEmpty;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + topPadding),
        child: Container(
          color: AppTheme.primaryBlue,
          padding: EdgeInsets.only(top: topPadding),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Text(
                  'Trip In Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.onlineGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.statusText.isNotEmpty ? ride.statusText : 'On Trip',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Customer Details Banner (Only live data)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasCustomerName ? ride.customer.name : 'Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasCustomerMobile)
                        Text(
                          ride.customer.mobile,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        )
                      else if (tripIdDisplay.isNotEmpty)
                        Text(
                          'Trip ID: #$tripIdDisplay',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                if (hasCustomerMobile)
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.call, color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
              ],
            ),
          ),

          // Main Live Navigation & Route View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Live Trip Info Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'TX#$tripIdDisplay',
                                style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (ride.tripType.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ride.tripType.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (ride.pickupTime.isNotEmpty || ride.startDate.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                '${ride.startDate} ${ride.pickupTime}'.trim(),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                              if (ride.fare > 0) ...[
                                const Spacer(),
                                Text(
                                  '₹ ${ride.fare.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Route Pickup & Drop Card (Live Addresses)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Route Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.circle, color: AppTheme.onlineGreen, size: 12),
                                Container(width: 2, height: 36, color: Colors.grey.shade300),
                                const Icon(Icons.location_on, color: Colors.red, size: 16),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Location',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ride.pickupLocation.isNotEmpty ? ride.pickupLocation : 'Pickup location',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Drop Location',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ride.dropLocation.isNotEmpty ? ride.dropLocation : 'Drop location',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Live Status Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.onlineGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.onlineGreen.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.onlineGreen.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.navigation, color: AppTheme.onlineGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ride in progress',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.onlineGreen,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Proceed towards the destination location',
                                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.onlineGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _onDropCustomer(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Drop Customer / Complete Trip',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
