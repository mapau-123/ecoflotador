import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

class AnimatedLevelBar extends StatelessWidget {
  const AnimatedLevelBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 9,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '${(value.clamp(0, 1).toDouble() * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value.clamp(0, 1).toDouble()),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return LinearProgressIndicator(
              minHeight: height,
              value: animatedValue,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(color),
            );
          },
        ),
      ),
    );
  }
}
