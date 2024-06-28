import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChart extends StatefulWidget {
  const DonutChart({Key? key}) : super(key: key);

  @override
  _DonutChartState createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  Map<String, double> binData = {
    'Half': 0,
    'Not Working': 0,
    'empty': 0,
    'full': 0,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('bins').get();

      Map<String, double> data = {
        'not full': 0,
        'Not Working': 0,
        'empty': 0,
        'full': 0,
      };

      for (var doc in snapshot.docs) {
        String status = doc['status'];
        if (data.containsKey(status)) {
          data[status] = data[status]! + 1;
        }
      }

      setState(() {
        binData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Bin Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      Container(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: _getSections(),
                            centerSpaceRadius: 50,
                            sectionsSpace: 4,
                            startDegreeOffset: -90,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLegend(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    double total = binData.values.fold(0, (sum, value) => sum + value);
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: '',
        ),
      ];
    }
    return binData.entries.map((entry) {
      return PieChartSectionData(
        color: _getColor(entry.key),
        value: entry.value,
        title: '',
        radius: 60,
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: binData.entries.map((entry) {
        double total = binData.values.fold(0, (sum, value) => sum + value);
        double percentage = (entry.value / total) * 100;
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getColor(entry.key),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key} (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getColor(String status) {
    switch (status) {
      case 'Half':
        return Colors.orange;
      case 'Not Working':
        return Colors.grey;
      case 'empty':
        return Colors.green;
      case 'full':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
