import 'package:flutter/material.dart';
import 'dart:math';

class GlowingMicPainterWrapper extends StatefulWidget {
  final Widget child;
  final bool glowing;
  final Color glowColor;

  const GlowingMicPainterWrapper({
    super.key,
    required this.child,
    required this.glowing,
    required this.glowColor,
  });

  @override
  State<GlowingMicPainterWrapper> createState() =>
      _GlowingMicPainterWrapperState();
}

class _GlowingMicPainterWrapperState extends State<GlowingMicPainterWrapper>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _arcAngle;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _arcAngle = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant GlowingMicPainterWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.glowing) {
      _rotationController.repeat();
      _opacityController.forward();
    } else {
      _rotationController.stop();
      _rotationController.reset();
      _opacityController.reverse();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_arcAngle, _opacityAnimation]),
            builder: (context, _) {
              return CustomPaint(
                size: const Size(140, 140),
                painter: GlowCirclePainter(
                  opacity: _opacityAnimation.value,
                  sweepAngle: _arcAngle.value,
                  glowColor: widget.glowColor,
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class GlowCirclePainter extends CustomPainter {
  final double opacity;
  final double sweepAngle;
  final Color glowColor;

  GlowCirclePainter({
    required this.opacity,
    required this.sweepAngle,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 40.0;
    final radius = size.width / 2 - strokeWidth / 2;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = glowColor.withAlpha(100)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant GlowCirclePainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.sweepAngle != sweepAngle;
}
