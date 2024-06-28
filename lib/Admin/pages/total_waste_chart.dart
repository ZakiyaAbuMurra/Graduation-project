import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalWasteChart extends StatefulWidget {
  TotalWasteChart({Key? key}) : super(key: key);

  @override
  _TotalWasteChartState createState() => _TotalWasteChartState();
}

class _TotalWasteChartState extends State<TotalWasteChart> {
  List<_WasteData> wasteDataList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWasteData();
  }

  Future<void> _fetchWasteData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('bins').get();

      Map<String, int> wasteData = {
        'paper': 0,
        'plastic': 0,
        'metal': 0,
        'glass': 0
      };

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var material = data['Material'].toString().toLowerCase();

        if (wasteData.containsKey(material)) {
          wasteData[material] = wasteData[material]! + 1;
        }
      }

      setState(() {
        wasteDataList = [
          _WasteData('Paper', wasteData['paper']!.toDouble(), Colors.yellow),
          _WasteData('Plastic', wasteData['plastic']!.toDouble(), Colors.blue),
          _WasteData('Metal', wasteData['metal']!.toDouble(), Colors.red),
          _WasteData('Glass', wasteData['glass']!.toDouble(), Colors.green),
        ];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching waste data: $e');
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Waste',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Number of Bins'),
                        interval: 1,
                      ),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        ColumnSeries<_WasteData, String>(
                          dataSource: wasteDataList,
                          xValueMapper: (_WasteData data, _) => data.type,
                          yValueMapper: (_WasteData data, _) => data.amount,
                          pointColorMapper: (_WasteData data, _) => data.color,
                          name: 'Waste',
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WasteData {
  _WasteData(this.type, this.amount, this.color);

  final String type;
  final double amount;
  final Color color;
}
