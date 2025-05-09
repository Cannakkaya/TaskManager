// Örnek: Gelişmiş İstatistikler
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/main.dart';

class TaskAnalyticsScreen extends StatelessWidget {
  final List<Task> tasks;

  const TaskAnalyticsScreen({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Analizi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Haftalık Tamamlanan Görevler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBorder: BorderSide(
                        color: Colors.blueGrey.withAlpha(204), // ~0.8 opaklık
                        width: 1,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} görev',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'Pzt',
                            'Sal',
                            'Çar',
                            'Per',
                            'Cum',
                            'Cmt',
                            'Paz'
                          ];
                          final int index = value.toInt();
                          if (index >= 0 && index < titles.length) {
                            return Text(
                              titles[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8)]),
                    BarChartGroupData(
                        x: 1, barRods: [BarChartRodData(toY: 10)]),
                    BarChartGroupData(
                        x: 2, barRods: [BarChartRodData(toY: 14)]),
                    BarChartGroupData(
                        x: 3, barRods: [BarChartRodData(toY: 15)]),
                    BarChartGroupData(
                        x: 4, barRods: [BarChartRodData(toY: 13)]),
                    BarChartGroupData(
                        x: 5, barRods: [BarChartRodData(toY: 10)]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 6)]),
                  ],
                ),
              ),
            ),
            // Diğer grafikler ve istatistikler...
          ],
        ),
      ),
    );
  }
}
