import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride_model.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import 'trip_completed_screen.dart';

class PaymentModeScreen extends StatefulWidget {
  final RideModel ride;
  const PaymentModeScreen({super.key, required this.ride});

  @override
  State<PaymentModeScreen> createState() => _PaymentModeScreenState();
}

class _PaymentModeScreenState extends State<PaymentModeScreen> {
  String _selectedMode = 'Cash';

  void _confirmPayment() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final success = await rideProvider.completeRide(widget.ride.bookingId, widget.ride.fare);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TripCompletedScreen(ride: widget.ride),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rideProvider.error ?? 'Failed to complete ride'),
          backgroundColor: AppTheme.offlineRed,
        ),
      );
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
                  'Select Payment Mode',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Fare Display Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Fare', style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
                  Text(
                    '₹ ${widget.ride.fare.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Select payment mode',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),

            // Payment Methods Card List
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.money, color: AppTheme.onlineGreen),
                        SizedBox(width: 12),
                        Text('Cash', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    value: 'Cash',
                    groupValue: _selectedMode,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (val) => setState(() => _selectedMode = val!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.qr_code, color: AppTheme.primaryBlue),
                        SizedBox(width: 12),
                        Text('UPI', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    value: 'UPI',
                    groupValue: _selectedMode,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (val) => setState(() => _selectedMode = val!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Card', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    value: 'Card',
                    groupValue: _selectedMode,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (val) => setState(() => _selectedMode = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Customer Payment Notice Banner
            Center(
              child: Text(
                'Customer will pay by $_selectedMode',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),

            // Confirm Payment Button
            ElevatedButton(
              onPressed: _confirmPayment,
              child: const Text('Confirm Payment Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
