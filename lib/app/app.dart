import 'package:flutter/material.dart';

import '../providers/eco_flotador_controller.dart';
import '../providers/eco_flotador_scope.dart';
import 'navigation/app_shell.dart';
import 'theme/app_theme.dart';

class EcoFlotadorApp extends StatelessWidget {
  const EcoFlotadorApp({super.key, required this.controller});

  final EcoFlotadorController controller;

  @override
  Widget build(BuildContext context) {
    return EcoFlotadorScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ECO FLOTADOR',
        theme: AppTheme.dark,
        home: const AppShell(),
      ),
    );
  }
}
