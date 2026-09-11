import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import 'animated_level_bar.dart';
import 'hmi_card.dart';
import 'status_pill.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.progress,
    this.status,
    this.statusColor,
    this.animateValue = true,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double? progress;
  final String? status;
  final Color? statusColor;
  final bool animateValue;

  @override
  Widget build(BuildContext context) {
    return HmiCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (status != null)
                StatusPill(
                  label: status!,
                  color: statusColor ?? AppColors.ecoGreen,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (animateValue)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _numericValue(value)),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, animated, child) {
                final suffix = value.contains('%') ? '%' : '';
                return Text(
                  '${animated.round()}$suffix',
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                );
              },
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 7),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (progress != null) ...[
            const SizedBox(height: 16),
            AnimatedLevelBar(value: progress!, color: color),
          ],
        ],
      ),
    );
  }

  double _numericValue(String source) {
    return double.tryParse(source.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }
}
