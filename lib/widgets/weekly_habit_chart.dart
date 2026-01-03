import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import 'package:intl/intl.dart';

/// Widget que muestra un gráfico semanal del progreso de hábitos
class WeeklyHabitChart extends StatefulWidget {
  const WeeklyHabitChart({super.key});

  @override
  State<WeeklyHabitChart> createState() => _WeeklyHabitChartState();
}

class _WeeklyHabitChartState extends State<WeeklyHabitChart> {
  Map<String, dynamic>? _weeklyStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
  }

  Future<void> _loadWeeklyStats() async {
    setState(() => _isLoading = true);

    final habitProvider = context.read<HabitProvider>();
    final stats = await habitProvider.getWeeklyProgress();

    setState(() {
      _weeklyStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weeklyStats == null || _weeklyStats!.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final dailyProgress =
        _weeklyStats!['dailyProgress'] as Map<DateTime, double>;
    final averageProgress = _weeklyStats!['averageProgress'] as double;
    final totalHabits = _weeklyStats!['totalHabits'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen Semanal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Hábitos',
                      totalHabits.toString(),
                      Icons.fact_check,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      context,
                      'Promedio',
                      '${averageProgress.toStringAsFixed(0)}%',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Gráfico de barras
        Text(
          'Progreso Diario',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dailyProgress.entries.map((entry) {
              return _buildBar(
                context,
                entry.key,
                entry.value,
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Leyenda
        _buildLegend(context),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
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

  Widget _buildBar(BuildContext context, DateTime date, double progress) {
    final isToday = DateTime.now().day == date.day &&
        DateTime.now().month == date.month &&
        DateTime.now().year == date.year;

    final barColor = _getBarColor(progress);
    final barHeight = (progress / 100) * 150;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Porcentaje
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? barColor : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),

            // Barra
            Container(
              width: double.infinity,
              height: barHeight < 20 ? 20 : barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                border: isToday ? Border.all(color: barColor, width: 2) : null,
              ),
            ),

            const SizedBox(height: 8),

            // Día de la semana
            Text(
              DateFormat('E', 'es').format(date).substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? barColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(double progress) {
    if (progress < 30) {
      return Colors.red[400]!;
    } else if (progress < 60) {
      return Colors.orange[400]!;
    } else if (progress < 90) {
      return Colors.blue[400]!;
    } else {
      return Colors.green[400]!;
    }
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leyenda',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.red[400]!, '< 30%'),
                _buildLegendItem(Colors.orange[400]!, '30-60%'),
                _buildLegendItem(Colors.blue[400]!, '60-90%'),
                _buildLegendItem(Colors.green[400]!, '≥ 90%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
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
}
