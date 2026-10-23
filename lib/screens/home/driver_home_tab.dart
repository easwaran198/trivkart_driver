import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import '../booking/new_request_dialog.dart';
import '../trip/trip_in_progress_screen.dart';

class DriverHomeTab extends StatelessWidget {
  const DriverHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);
    final driver = driverProvider.driver;
    final dashboardDetails = driverProvider.dashboardDetails;
    final isOnline = driverProvider.isOnline;
    final newRequests = rideProvider.newRequests.isNotEmpty 
        ? rideProvider.newRequests 
        : rideProvider.newBookings;
    final activeRide = rideProvider.activeRide ?? dashboardDetails?.activeRide;
    final earnings = rideProvider.earnings;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    final todayEarnings = (dashboardDetails?.todayEarnings ?? 0.0) > 0 
        ? dashboardDetails!.todayEarnings 
        : (earnings?.today.amount ?? 0.0);
    final todayTrips = (dashboardDetails?.todayRides ?? 0) > 0 
        ? dashboardDetails!.todayRides 
        : (earnings?.today.rides ?? 0);

    final totalEarnings = (dashboardDetails?.totalEarnings ?? 0.0) > 0 
        ? dashboardDetails!.totalEarnings 
        : (earnings?.total.amount ?? 0.0);
    final totalTrips = (dashboardDetails?.totalTripCount ?? 0) > 0 
        ? dashboardDetails!.totalTripCount 
        : (earnings?.total.rides ?? 0);

    final monthEarnings = (dashboardDetails?.monthEarnings ?? 0.0) > 0 
        ? dashboardDetails!.monthEarnings 
        : (earnings?.month.amount ?? 0.0);
    final monthTrips = (dashboardDetails?.monthRides ?? 0) > 0 
        ? dashboardDetails!.monthRides 
        : (earnings?.month.rides ?? 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await driverProvider.fetchUserInfo();
            await driverProvider.fetchDashboardDetails();
            await rideProvider.fetchNewRequests();
            await rideProvider.fetchMyBookings(1);
            await rideProvider.fetchActiveRide();
            await rideProvider.fetchEarnings();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(left: 16, right: 16, top: topPadding + 12, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Online status toggle + Notifications)
                Row(
                  children: [
                    // Profile Avatar & Name (Wrapped with Expanded to prevent overflow)
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 22),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver != null && driver.name.isNotEmpty
                                      ? 'Hello, ${driver.name.split(' ').first}'
                                      : 'Hello, Driver',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isOnline ? 'Ready to drive' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOnline ? AppTheme.onlineGreen : AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Bell Icon
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined, size: 26, color: AppTheme.textDark),
                          if ((driverProvider.notifications?.unreadCount ?? 0) > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${driverProvider.notifications!.unreadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        driverProvider.fetchNotifications();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Active Ride Banner (If ride is in progress)
                if (activeRide != null) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripInProgressScreen(ride: activeRide),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trip In Progress',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  'Drop: ${activeRide.dropLocation}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Earnings Cards Section (Today & Total + Month if available)
                Row(
                  children: [
                    // Today's Earnings Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Today",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.onlineGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$todayTrips trips',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onlineGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹ ${todayEarnings.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Total Earnings Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Earnings",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$totalTrips trips',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹ ${totalEarnings.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (monthEarnings > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_month, size: 16, color: AppTheme.textMuted),
                            SizedBox(width: 6),
                            Text(
                              "This Month",
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          '₹ ${monthEarnings.toStringAsFixed(0)} ($monthTrips trips)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // New Booking Requests Section (Horizontal Scrollable List)
                if (newRequests.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'New Requests',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${newRequests.length} New',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (newRequests.length > 1)
                        const Row(
                          children: [
                            Text(
                              'Swipe',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryBlue),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 235,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: newRequests.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final ride = newRequests[index];
                        final cardWidth = MediaQuery.of(context).size.width * 0.85;

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => NewRequestDialog(ride: ride),
                            );
                          },
                          child: Container(
                            width: cardWidth.clamp(280.0, 340.0),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.18),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Row: ID, Trip Type & Fare
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'TX#${ride.bookingId.isNotEmpty ? ride.bookingId : ride.tripId}',
                                          style: const TextStyle(
                                            color: AppTheme.primaryBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${ride.tripType.toUpperCase()} • ${ride.noOfPassengers}P',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹ ${ride.fare.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),

                              // Date, Time & Distance Info
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${ride.startDate} ${ride.pickupTime}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${ride.distanceKm} km',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Pickup & Drop Locations Timeline
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.circle, color: AppTheme.onlineGreen, size: 10),
                                      Container(width: 1.5, height: 18, color: Colors.grey.shade300),
                                      const Icon(Icons.location_on, color: Colors.red, size: 12),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ride.pickupLocation,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: AppTheme.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          ride.dropLocation,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: AppTheme.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Action Buttons (Decline & Accept)
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.offlineRed,
                                        side: const BorderSide(color: AppTheme.offlineRed, width: 1.2),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () async {
                                        final success = await rideProvider.declineRide(ride.bookingId);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success ? 'Ride request declined.' : 'Failed to decline ride.',
                                              ),
                                              backgroundColor: AppTheme.offlineRed,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Decline',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.onlineGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () async {
                                        final success = await rideProvider.acceptRide(ride.bookingId);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? 'Ride accepted! Waiting for confirmation.'
                                                    : 'Failed to accept ride.',
                                              ),
                                              backgroundColor:
                                                  success ? AppTheme.onlineGreen : AppTheme.offlineRed,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_outline, size: 15),
                                          SizedBox(width: 4),
                                          Text(
                                            'Accept Ride',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

                // Trips Summary Section
                const Text(
                  "Trips Summary",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Total Bookings Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(dashboardDetails?.totalBookings ?? 0) > 0 ? dashboardDetails!.totalBookings : totalTrips}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(height: 4),
                            const Text('Total Bookings', style: TextStyle(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Accepted Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dashboardDetails?.accepted ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                            const SizedBox(height: 4),
                            const Text('Accepted', style: TextStyle(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Completed Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dashboardDetails?.completed ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onlineGreen),
                            ),
                            const SizedBox(height: 4),
                            const Text('Completed', style: TextStyle(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Cancelled Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dashboardDetails?.cancelled ?? 0}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.offlineRed),
                            ),
                            const SizedBox(height: 4),
                            const Text('Cancelled', style: TextStyle(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
