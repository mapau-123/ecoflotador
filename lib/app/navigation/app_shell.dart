import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../providers/eco_flotador_scope.dart';
import '../../screens/control/control_screen.dart';
import '../../screens/data/data_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../widgets/bluetooth_indicator.dart';
import '../../widgets/demo_banner.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ControlScreen(),
    DataScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = EcoFlotadorScope.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: AppColors.deepOcean,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Row(
          children: [
            _AppMark(),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ECO FLOTADOR',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                Text(
                  'CONTROL HMI',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: BluetoothIndicator(
                  controller: controller,
                  compact: MediaQuery.sizeOf(context).width < 430,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (controller.settings.demoMode)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: DemoBanner(),
              ),
            Expanded(
              child: IndexedStack(index: _index, children: _screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.gamepad_outlined),
            selectedIcon: Icon(Icons.gamepad_rounded),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart_rounded),
            label: 'Datos',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.ecoGreen.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.ecoGreen.withValues(alpha: .4)),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.water_rounded, color: AppColors.seaBlue, size: 26),
          Positioned(
            top: 4,
            right: 5,
            child: Icon(Icons.eco_rounded, color: AppColors.ecoGreen, size: 16),
          ),
        ],
      ),
    );
  }
}
