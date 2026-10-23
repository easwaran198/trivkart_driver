import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride_model.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import 'cancel_booking_dialog.dart';
import '../trip/otp_verification_dialog.dart';

class BookingDetailsScreen extends StatelessWidget {
  final RideModel ride;
  const BookingDetailsScreen({super.key, required this.ride});

  void _onStartTrip(BuildContext context) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const OtpVerificationDialog(isStartTrip: true),
    );

    if (result != null && context.mounted) {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      String? otp;
      String? odometer;
      String? imagePath;

      if (result is StartTripResult) {
        otp = result.otp;
        odometer = result.odometerReading;
        imagePath = result.imagePath;
      }

      final success = await rideProvider.startRide(
        ride.bookingId,
        otp: otp ?? '',
        odometerValue: odometer ?? '',
        odometerPhotoPath: imagePath ?? '',
      );
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip Started successfully with Odometer verification!'),
              backgroundColor: AppTheme.onlineGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(rideProvider.error ?? 'Failed to start trip'),
              backgroundColor: AppTheme.offlineRed,
            ),
          );
        }
      }
    }
  }

  void _onCancelBooking(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => CancelBookingDialog(bookingId: ride.bookingId),
    );

    if (reason != null && context.mounted) {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      await rideProvider.cancelRide(ride.bookingId, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking cancelled: $reason')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Booking ID & Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Booking ID', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        const SizedBox(height: 4),
                        Text('TX${ride.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.onlineGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ride.status.toUpperCase(),
                        style: const TextStyle(color: AppTheme.onlineGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Route Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppTheme.textMuted),
                        const SizedBox(width: 8),
                        Text('${ride.startDate} ${ride.pickupTime}', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.circle, color: AppTheme.onlineGreen, size: 12),
                            Container(width: 2, height: 32, color: Colors.grey.shade300),
                            const Icon(Icons.location_on, color: Colors.red, size: 14),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride.pickupLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 22),
                              Text(ride.dropLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Fare', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text('₹ ${ride.fare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Customer Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride.customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(ride.customer.mobile, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: AppTheme.primaryBlue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.message, color: AppTheme.primaryBlue),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Start Trip & Cancel Booking)
            if (ride.status != 'completed' && ride.status != 'cancelled') ...[
              ElevatedButton(
                onPressed: () => _onStartTrip(context),
                child: const Text('Start Trip'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.offlineRed,
                  side: const BorderSide(color: AppTheme.offlineRed, width: 1.5),
                ),
                onPressed: () => _onCancelBooking(context),
                child: const Text('Cancel Booking'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
