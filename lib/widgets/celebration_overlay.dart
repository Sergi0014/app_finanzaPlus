import 'dart:math';
import 'package:flutter/material.dart';

/// Widget de celebración animada que se muestra al completar un hábito
class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const CelebrationOverlay({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();

  /// Muestra la animación de celebración sobre el contexto dado
  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CelebrationAnimation(
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _CelebrationAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const _CelebrationAnimation({required this.onComplete});

  @override
  State<_CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<_CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Emoji> _emojis;

  final List<String> _celebrationEmojis = [
    '🎉',
    '✨',
    '🌟',
    '⭐',
    '💫',
    '🎊',
    '👏',
    '🔥',
    '💪',
    '🏆',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _emojis = List.generate(
      15,
      (index) => _Emoji(
        emoji: _celebrationEmojis[Random().nextInt(_celebrationEmojis.length)],
        controller: _controller,
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children:
                  _emojis.map((emoji) => emoji.build(context, size)).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _Emoji {
  final String emoji;
  final AnimationController controller;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double size;

  _Emoji({
    required this.emoji,
    required this.controller,
  })  : startX = Random().nextDouble(),
        startY = 0.3 + Random().nextDouble() * 0.2, // Centro de la pantalla
        endX = Random().nextDouble(),
        endY = -0.2, // Hacia arriba
        rotation = Random().nextDouble() * 4 * pi,
        size = 30 + Random().nextDouble() * 20;

  Widget build(BuildContext context, Size screenSize) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    final x = screenSize.width * (startX + (endX - startX) * animation.value);
    final y = screenSize.height * (startY + (endY - startY) * animation.value);
    final opacity = 1.0 - animation.value;
    final currentRotation = rotation * animation.value;

    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: currentRotation,
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: size,
            ),
          ),
        ),
      ),
    );
  }
}
