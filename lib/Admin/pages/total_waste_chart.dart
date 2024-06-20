
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
