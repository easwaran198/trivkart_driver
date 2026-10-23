import 'package:flutter/material.dart';
import '../../models/driver_model.dart';
import '../../theme/app_theme.dart';

class VehicleInfoScreen extends StatelessWidget {
  final VehicleModel? vehicle;
  const VehicleInfoScreen({super.key, this.vehicle});

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
                  'Vehicle Information',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Vehicle Car Graphic Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car_filled_rounded,
                    size: 100,
                    color: AppTheme.primaryBlue.withOpacity(0.8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vehicle?.model.isNotEmpty == true ? vehicle!.model : 'Toyota Etios',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Text(
                      vehicle?.plateNo.isNotEmpty == true ? vehicle!.plateNo : 'KA01AB1234',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Specs Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSpecRow('Vehicle Number', vehicle?.plateNo.isNotEmpty == true ? vehicle!.plateNo : 'KA01AB1234'),
                    const Divider(height: 24),
                    _buildSpecRow('Vehicle Model', vehicle?.model.isNotEmpty == true ? vehicle!.model : 'Toyota Etios'),
                    const Divider(height: 24),
                    _buildSpecRow('Vehicle Type', vehicle?.type.isNotEmpty == true ? vehicle!.type : 'Sedan'),
                    const Divider(height: 24),
                    _buildSpecRow('Vehicle Color', 'White'),
                    const Divider(height: 24),
                    _buildSpecRow('Year', '2020'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Edit Information Button
            OutlinedButton(
              onPressed: () {},
              child: const Text('Edit Information'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }
}
