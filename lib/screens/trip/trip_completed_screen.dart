import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ride_model.dart';
import '../../theme/app_theme.dart';

class TripCompletedScreen extends StatelessWidget {
  final RideModel ride;
  const TripCompletedScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Checkmark Circle Icon with Confetti Style
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Trip Completed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                "Great job! You've completed the trip.",
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 32),

              // Trip Details Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, color: AppTheme.onlineGreen, size: 12),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride.pickupLocation,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride.dropLocation,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Fare', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Text(
                            '₹ ${ride.fare.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Paid by customer (${ride.paymentMode})',
                          style: const TextStyle(fontSize: 12, color: AppTheme.onlineGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Finish Action Button
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
