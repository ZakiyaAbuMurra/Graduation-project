import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/bin_info_card.dart';
import 'package:recyclear/Admin/pages/dount_chart.dart';
import 'package:recyclear/Admin/pages/driver_info_card.dart';
import 'package:recyclear/Admin/pages/total_waste_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kIsWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DonutChart(),
            const SizedBox(height: 20),
            UserInfoCards(),
            const SizedBox(height: 20),
            BinInfoCards(),
            TotalWasteChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: size.height * 0.55, // Adjust height as needed
                    child: DonutChart(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: size.height * 0.55, // Adjust height as needed
                    child: TotalWasteChart(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: size.height * 0.4, // Adjust height as needed
                    child: UserInfoCards(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: size.height * 0.4, // Adjust height as needed
                    child: BinInfoCards(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
