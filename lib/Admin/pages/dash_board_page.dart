import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/bin_info_card.dart';
import 'package:recyclear/Admin/pages/dount_chart.dart';
import 'package:recyclear/Admin/pages/driver_info_card.dart';
import 'package:recyclear/Admin/pages/total_waste_chart.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
      ),
    );
  }
}
