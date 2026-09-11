import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

class HmiCard extends StatelessWidget {
  const HmiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(
        color: accent?.withValues(alpha: 0.38) ?? AppColors.divider,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: AppColors.card,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
