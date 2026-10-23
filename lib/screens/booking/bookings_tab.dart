import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ride_model.dart';
import 'booking_details_screen.dart';
import 'cancel_booking_dialog.dart';
import '../trip/otp_verification_dialog.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final status = _tabController.index + 1; // 1: New, 2: Accepted, 3: Completed, 4: Cancelled
        Provider.of<RideProvider>(context, listen: false).fetchMyBookings(status);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      rideProvider.fetchMyBookings(1);
      rideProvider.fetchMyBookings(2);
      rideProvider.fetchMyBookings(3);
      rideProvider.fetchMyBookings(4);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onStartRide(BuildContext context, RideModel ride) async {
    if (!ride.isAdminApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for admin confirmation. Cannot start ride yet.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
              content: Text('Ride Started successfully with Odometer verification!'),
              backgroundColor: AppTheme.onlineGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(rideProvider.error ?? 'Failed to start ride'),
              backgroundColor: AppTheme.offlineRed,
            ),
          );
        }
      }
    }
  }

  void _onCancelRide(BuildContext context, RideModel ride) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => CancelBookingDialog(bookingId: ride.bookingId),
    );

    if (reason != null && context.mounted) {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      final success = await rideProvider.cancelRide(ride.bookingId, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Booking cancelled: $reason' : 'Failed to cancel booking'),
            backgroundColor: success ? AppTheme.onlineGreen : AppTheme.offlineRed,
          ),
        );
      }
    }
  }

  void _onAcceptRide(BuildContext context, RideModel ride) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final success = await rideProvider.acceptRide(ride.bookingId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Ride accepted! Waiting for admin approval.'
              : 'Failed to accept ride.',
        ),
        backgroundColor: success ? AppTheme.onlineGreen : AppTheme.offlineRed,
      ),
    );
  }

  Widget _buildRideList(List<RideModel> rides, int status) {
    String tabTitle = 'New Requests';
    Color badgeColor = AppTheme.primaryBlue;
    if (status == 2) {
      tabTitle = 'Accepted';
      badgeColor = Colors.orange;
    } else if (status == 3) {
      tabTitle = 'Completed';
      badgeColor = AppTheme.onlineGreen;
    } else if (status == 4) {
      tabTitle = 'Cancelled';
      badgeColor = AppTheme.offlineRed;
    }

    if (rides.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await Provider.of<RideProvider>(context, listen: false).fetchMyBookings(status);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No $tabTitle Found',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<RideProvider>(context, listen: false).fetchMyBookings(status);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailsScreen(ride: ride),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Booking ID & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Booking ID: #${ride.bookingId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (ride.tripId.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${ride.tripId})',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ride.statusText.isNotEmpty
                                ? ride.statusText.toUpperCase()
                                : ride.status.toUpperCase(),
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Customer Name & Mobile if available
                    if (ride.customer.name.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 4),
                          Text(
                            ride.customer.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          if (ride.customer.mobile.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  ${ride.customer.mobile}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Date & Pickup Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          '${ride.startDate} ${ride.pickupTime}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const Spacer(),
                        Text(
                          '${ride.distanceKm} km',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Pickup & Drop Address Timeline
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, color: AppTheme.onlineGreen, size: 10),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride.pickupLocation,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride.dropLocation,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Footer: Trip Type, Passengers & Fare
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${ride.tripType.toUpperCase()} • ${ride.noOfPassengers} Passengers',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        Text(
                          '₹ ${ride.fare.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),

                    // Action Buttons for Accepted List (status == 2)
                    if (status == 2) ...[
                      const Divider(height: 20),
                      if (ride.isAdminApproved)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.onlineGreen,
                                  minimumSize: const Size(0, 42),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => _onStartRide(context, ride),
                                child: const Text('Start Ride', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 42),
                                  padding: EdgeInsets.zero,
                                  foregroundColor: AppTheme.offlineRed,
                                  side: const BorderSide(color: AppTheme.offlineRed, width: 1.2),
                                ),
                                onPressed: () => _onCancelRide(context, ride),
                                child: const Text('Cancel Ride', style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_top_rounded, size: 16, color: Colors.orange.shade800),
                              const SizedBox(width: 8),
                              Text(
                                'Waiting for admin confirmation',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                    // Action Buttons for New Requests (status == 1)
                    if (status == 1) ...[
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 42),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => _onAcceptRide(context, ride),
                              child: const Text('Accept', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 42),
                                padding: EdgeInsets.zero,
                                foregroundColor: AppTheme.offlineRed,
                                side: const BorderSide(color: AppTheme.offlineRed, width: 1.2),
                              ),
                              onPressed: () => _onCancelRide(context, ride),
                              child: const Text('Decline', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 48 + topPadding),
        child: Container(
          color: AppTheme.primaryBlue,
          padding: EdgeInsets.only(top: topPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: kToolbarHeight,
                child: Center(
                  child: Text(
                    'My Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'New Requests'),
                  Tab(text: 'Accepted'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: rideProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRideList(rideProvider.newBookings, 1),
                _buildRideList(rideProvider.acceptedBookings, 2),
                _buildRideList(rideProvider.completedBookings, 3),
                _buildRideList(rideProvider.cancelledBookings, 4),
              ],
            ),
    );
  }
}
