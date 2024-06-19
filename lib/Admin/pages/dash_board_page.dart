import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
              DonutChart(),
              SizedBox(height: 20),
              UserInfoCards(),
              SizedBox(height: 20),
              TotalWasteChart(),
            ],
          ),
        ),
      ),
    );
  }
}

class DonutChart extends StatelessWidget {
  const DonutChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Bin Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        color: Colors.yellow, value: 25, title: 'Half'),
                    PieChartSectionData(
                        color: Colors.grey, value: 25, title: 'Not Working'),
                    PieChartSectionData(
                        color: Colors.green, value: 25, title: 'Empty'),
                    PieChartSectionData(
                        color: Colors.red, value: 25, title: 'Full'),
                  ],
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
}

class UserInfoCards extends StatelessWidget {
  UserInfoCards({Key? key}) : super(key: key);

  final List<Map<String, String>> userInfo = [
    {
      'name': 'Driver 1',
      'phone': '+95 *****',
      'truck': '126789',
      'area': 'Area 1',
    },
    {
      'name': 'Driver 2',
      'phone': '+95 *****',
      'truck': '126790',
      'area': 'Area 2',
    },
    {
      'name': 'Driver 3',
      'phone': '+95 *****',
      'truck': '126791',
      'area': 'Area 3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: userInfo.map((info) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 30,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text('Driver Name: ${info['name']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('Driver Phone: ${info['phone']}'),
                  SizedBox(height: 5),
                  Text('Truck Number: ${info['truck']}'),
                  SizedBox(height: 5),
                  Text('Area: ${info['area']}'),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TotalWasteChart extends StatelessWidget {
  TotalWasteChart({Key? key}) : super(key: key);

  final List<BarChartGroupData> barChartData = List.generate(12, (index) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(toY: index.toDouble() + 5, color: Colors.yellow),
        BarChartRodData(toY: index.toDouble() + 10, color: Colors.blue),
        BarChartRodData(toY: index.toDouble() + 15, color: Colors.red),
        BarChartRodData(toY: index.toDouble() + 20, color: Colors.orange),
      ],
    );
  });

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
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barChartData,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('JAN', style: style);
                              break;
                            case 1:
                              text = const Text('FEB', style: style);
                              break;
                            case 2:
                              text = const Text('MAR', style: style);
                              break;
                            case 3:
                              text = const Text('APR', style: style);
                              break;
                            case 4:
                              text = const Text('MAY', style: style);
                              break;
                            case 5:
                              text = const Text('JUN', style: style);
                              break;
                            case 6:
                              text = const Text('JUL', style: style);
                              break;
                            case 7:
                              text = const Text('AUG', style: style);
                              break;
                            case 8:
                              text = const Text('SEP', style: style);
                              break;
                            case 9:
                              text = const Text('OCT', style: style);
                              break;
                            case 10:
                              text = const Text('NOV', style: style);
                              break;
                            case 11:
                              text = const Text('DEC', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: text,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
