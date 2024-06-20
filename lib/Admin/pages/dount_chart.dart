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
    'Empty': 0,
    'Full': 0,
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
        'Half': 0,
        'Not Working': 0,
        'empty': 0,
        'full': 0,
      };

      for (var doc in snapshot.docs) {
        String status = doc['status'];
        print('The status bin -- fetchData :  ${status} ');
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Bin Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Container(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _getSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
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
          title: 'No Data',
        ),
      ];
    }
    return binData.entries.map((entry) {
      double percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: _getColor(entry.key),
        value: entry.value,
        title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
      );
    }).toList();
  }

  Color _getColor(String status) {
    switch (status) {
      case 'Half':
        return Colors.yellow;
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
