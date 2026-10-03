import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import '../../theme/app_theme.dart';
import 'otp_verification_dialog.dart';
import 'payment_mode_screen.dart';

class TripInProgressScreen extends StatelessWidget {
  final RideModel ride;
  const TripInProgressScreen({super.key, required this.ride});

  void _onDropCustomer(BuildContext context) async {
    final otpVerified = await showDialog<bool>(
      context: context,
      builder: (context) => const OtpVerificationDialog(isStartTrip: false),
    );

    if (otpVerified == true && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentModeScreen(ride: ride),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Trip In Progress'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.onlineGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'On Trip',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Details Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.customer.name.isNotEmpty ? ride.customer.name : 'John Doe',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        ride.customer.mobile.isNotEmpty ? ride.customer.mobile : '+91 98765 43210',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.call, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Map Area Placeholder with polyline route design
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              child: Stack(
                children: [
                  // Map Graphic background simulation
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 80, color: AppTheme.primaryBlue.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text(
                          'Live Map Navigation View',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ),

                  // Route pickup & drop card floating over map
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, color: AppTheme.onlineGreen, size: 12),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ride.pickupLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ride.dropLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Summary Card & Drop Customer Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Distance Left', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                          '${ride.distanceKm > 0 ? ride.distanceKm : 18} km',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.grey.shade300),
                    const Column(
                      children: [
                        Text('Estimated Time', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        SizedBox(height: 4),
                        Text(
                          '25 mins',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _onDropCustomer(context),
                  child: const Text('Drop Customer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
