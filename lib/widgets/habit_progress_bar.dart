import 'package:flutter/material.dart';

/// Barra de progreso personalizada para mostrar el porcentaje de hábitos completados
class HabitProgressBar extends StatelessWidget {
  final double progress; // 0-100

  const HabitProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final progressFraction = progress / 100;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Barra de progreso
          FractionallySizedBox(
            widthFactor: progressFraction,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getProgressColors(progress),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Texto centrado
          Center(
            child: Text(
              '${progress.toStringAsFixed(0)}%',
              style: TextStyle(
                color: progressFraction > 0.5 ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getProgressColors(double progress) {
    if (progress < 30) {
      return [Colors.red[400]!, Colors.red[600]!];
    } else if (progress < 60) {
      return [Colors.orange[400]!, Colors.orange[600]!];
    } else if (progress < 90) {
      return [Colors.blue[400]!, Colors.blue[600]!];
    } else {
      return [Colors.green[400]!, Colors.green[600]!];
    }
  }
}
