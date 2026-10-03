import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CancelBookingDialog extends StatefulWidget {
  final String bookingId;
  const CancelBookingDialog({super.key, required this.bookingId});

  @override
  State<CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<CancelBookingDialog> {
  String _selectedReason = 'Customer not reachable';
  final _additionalDetailsController = TextEditingController();

  final List<String> _reasons = [
    'Customer not reachable',
    'Pickup location issue',
    'Vehicle issue',
    'Traffic issue',
    'Personal reason',
    'Other reason',
  ];

  @override
  void dispose() {
    _additionalDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Reason for cancelling',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),

            // Radio options list
            Column(
              children: _reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason, style: const TextStyle(fontSize: 14)),
                  value: reason,
                  groupValue: _selectedReason,
                  activeColor: AppTheme.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedReason = val;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Additional details input
            TextField(
              controller: _additionalDetailsController,
              decoration: InputDecoration(
                hintText: 'Additional details (optional)',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Cancel Booking Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              onPressed: () {
                Navigator.pop(context, _selectedReason);
              },
              child: const Text('Cancel Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
