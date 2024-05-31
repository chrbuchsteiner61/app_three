import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Putting Results')),
      body: FutureBuilder<List<PuttingResult>>(
        future: DatabaseHelper().getResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final results = snapshot.data;
          return Column(
            children: [
              Expanded(child: ResultsChart(results)),
            ],
          );
        },
      ),
    );
  }
}

class ResultsChart extends StatelessWidget {
  final List<PuttingResult>? results;

  const ResultsChart(this.results, {super.key});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots1m = [];
    List<FlSpot> spots2m = [];
    List<FlSpot> spots3m = [];

    for (var result in results!) {
      double dateInMillis = DateTime.parse(result.dateOfPractice).millisecondsSinceEpoch.toDouble();

      if (result.distance == 1) {
        spots1m.add(FlSpot(dateInMillis, result.successRate));
      } else if (result.distance == 2) {
        spots2m.add(FlSpot(dateInMillis, result.successRate));
      } else if (result.distance == 3) {
        spots3m.add(FlSpot(dateInMillis, result.successRate));
      }
    }

    return Padding(
    padding: const EdgeInsets.all(36.0),
    child:LineChart(
      LineChartData(
         titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: calculateBottomInterval(results!),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    DateFormat('dd.MM, hh:mm').format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
                    style: const TextStyle(color: Colors.black, fontSize: 8),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots1m,
              isStepLineChart: true,
              barWidth: 3,
              color: Colors.yellow,
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: spots2m,
              isStepLineChart: true,
              barWidth: 3,
              color: Colors.red,
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: spots3m,
              isStepLineChart: true,
              barWidth: 3,
              color: Colors.blue,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),);
    
  }

  double calculateBottomInterval(List<PuttingResult> results) {
    if (results.length < 2) {
      return 1;
    }
    double totalMillis = DateTime.parse(results.last.dateOfPractice).millisecondsSinceEpoch.toDouble() -
                         DateTime.parse(results.first.dateOfPractice).millisecondsSinceEpoch.toDouble();
    return totalMillis / 2;  // Divide by the number of intervals you want
  }
}