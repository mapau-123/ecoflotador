import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Modo demostración activo',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF15583F), Color(0xFF11617A)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, color: AppColors.ink, size: 18),
            SizedBox(width: 8),
            Text(
              'MODO DEMOSTRACIÓN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
