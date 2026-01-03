import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';

/// Widget que muestra un gráfico de barras con las estadísticas mensuales
class MonthlyHabitChart extends StatelessWidget {
  const MonthlyHabitChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final monthlyStats = habitProvider.getMonthlyStats();

        if (monthlyStats.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No hay datos mensuales disponibles',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Progreso Mensual',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Resumen de estadísticas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMonthlyStatsSummary(context, monthlyStats),
            ),

            const SizedBox(height: 24),

            // Gráfico de barras
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date =
                              monthlyStats[groupIndex]['date'] as DateTime;
                          final value = rod.toY;
                          return BarTooltipItem(
                            '${DateFormat('d MMM', 'es').format(date)}\n${value.toStringAsFixed(0)}%',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < monthlyStats.length) {
                              final date = monthlyStats[value.toInt()]['date']
                                  as DateTime;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('d', 'es').format(date),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                        left: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    barGroups: monthlyStats.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final percentage = data['percentage'] as double;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: percentage,
                            color: _getColorForPercentage(percentage),
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Leyenda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildLegend(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyStatsSummary(
    BuildContext context,
    List<Map<String, dynamic>> stats,
  ) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final totalDays = stats.length;
    final avgPercentage =
        stats.map((s) => s['percentage'] as double).reduce((a, b) => a + b) /
            totalDays;
    final perfectDays =
        stats.where((s) => (s['percentage'] as double) == 100).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.calendar_month,
              label: 'Días',
              value: totalDays.toString(),
              color: Colors.blue,
            ),
            _buildStatItem(
              context,
              icon: Icons.trending_up,
              label: 'Promedio',
              value: '${avgPercentage.toStringAsFixed(0)}%',
              color: Colors.green,
            ),
            _buildStatItem(
              context,
              icon: Icons.star,
              label: 'Días perfectos',
              value: perfectDays.toString(),
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Excelente (80-100%)', Colors.green),
        _buildLegendItem('Bueno (60-79%)', Colors.blue),
        _buildLegendItem('Regular (40-59%)', Colors.orange),
        _buildLegendItem('Bajo (<40%)', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.blue;
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
