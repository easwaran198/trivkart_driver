import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';

class EarningsTab extends StatefulWidget {
  const EarningsTab({super.key});

  @override
  State<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  String _selectedPeriod = 'Today';
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(context, listen: false).fetchEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final earnings = rideProvider.earnings;

    double amount = earnings?.today.amount ?? 2450.0;
    int rides = earnings?.today.rides ?? 8;
    if (_selectedPeriod == 'Month') {
      amount = earnings?.month.amount ?? 18750.0;
      rides = earnings?.month.rides ?? 42;
    } else if (_selectedPeriod == 'Total') {
      amount = earnings?.total.amount ?? 145600.0;
      rides = earnings?.total.rides ?? 312;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Dropdown & Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: _selectedPeriod,
                          underline: const SizedBox(),
                          items: ['Today', 'Month', 'Total'].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPeriod = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Total Earnings', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Trips', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            Text('$rides', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.grey.shade300),
                        const Column(
                          children: [
                            Text('Online Time', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                            SizedBox(height: 4),
                            Text('12.5 hrs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Earnings Breakdown Section
            const Text('Earnings Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildBreakdownRow('Trip Earnings', '₹ ${(amount * 0.9).toStringAsFixed(0)}'),
                    const Divider(height: 20),
                    _buildBreakdownRow('Incentives', '₹ 200'),
                    const Divider(height: 20),
                    _buildBreakdownRow('Other Earnings', '₹ 0'),
                    const Divider(height: 20),
                    _buildBreakdownRow('Deductions', '₹ 0'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // View Earnings History Toggle Button
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _showHistory = !_showHistory;
                });
              },
              child: Text(_showHistory ? 'Hide Earnings History' : 'View Earnings History'),
            ),

            if (_showHistory) ...[
              const SizedBox(height: 20),
              const Text('Earnings History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 12),
              _buildHistoryCard('26 May 2024', '₹ 2,450', '08 Trips'),
              _buildHistoryCard('25 May 2024', '₹ 2,350', '07 Trips'),
              _buildHistoryCard('24 May 2024', '₹ 2,150', '06 Trips'),
              _buildHistoryCard('23 May 2024', '₹ 1,950', '05 Trips'),
              _buildHistoryCard('22 May 2024', '₹ 1,850', '06 Trips'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildHistoryCard(String date, String amount, String trips) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(trips, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue)),
      ),
    );
  }
}
