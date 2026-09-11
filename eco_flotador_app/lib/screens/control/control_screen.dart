import 'package:flutter/material.dart';
 
import '../../app/theme/app_colors.dart';
import '../../models/vehicle_state.dart';
import '../../providers/eco_flotador_scope.dart';
import '../../widgets/belt_control.dart';
import '../../widgets/hmi_card.dart';
import '../../widgets/joystick.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/speed_control.dart';
import '../../widgets/status_pill.dart';
 
class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final controller = EcoFlotadorScope.of(context);
    final enabled = controller.controlsEnabled;
    final movement = controller.vehicle.movement;
 
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                title: 'Control manual',
                subtitle: enabled
                    ? 'Mantenga el joystick en la dirección deseada'
                    : 'Conecte el ESP32 para habilitar los controles',
                trailing: StatusPill(
                  label: _movementLabel(movement),
                  color: movement == Movement.stopped
                      ? AppColors.muted
                      : AppColors.ecoGreen,
                  icon: Icons.directions_boat_filled_rounded,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 720;
                  final joystickCard = HmiCard(
                    accent: enabled ? AppColors.seaBlue : AppColors.danger,
                    child: Column(
                      children: [
                        Joystick(
                          enabled: enabled,
                          movement: movement,
                          onMove: controller.move,
                          onStop: () => controller.move(Movement.stopped),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          enabled
                              ? 'Suelte el joystick para detener'
                              : 'CONTROL BLOQUEADO · SIN CONEXIÓN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: enabled ? AppColors.muted : AppColors.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .35,
                          ),
                        ),
                      ],
                    ),
                  );
                  final commandPanel = _CommandPanel(
                    movement: movement,
                    enabled: enabled,
                    onMove: controller.move,
                  );
 
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: joystickCard),
                            const SizedBox(width: 14),
                            Expanded(flex: 2, child: commandPanel),
                          ],
                        )
                      : Column(
                          children: [
                            joystickCard,
                            const SizedBox(height: 14),
                            commandPanel,
                          ],
                        );
                },
              ),
              const SizedBox(height: 14),
              SpeedControl(controller: controller, enabled: enabled),
              const SizedBox(height: 14),
              Semantics(
                button: true,
                label:
                    'Parada de emergencia. Detiene motores y banda recolectora.',
                child: SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: controller.emergencyStop,
                    icon: const Icon(Icons.stop_circle_rounded, size: 32),
                    label: const Text(
                      'STOP · EMERGENCIA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BeltControl(controller: controller, enabled: enabled),
            ],
          ),
        ),
      ),
    );
  }
 
  static String _movementLabel(Movement movement) => switch (movement) {
    Movement.forward => 'AVANZANDO',
    Movement.backward => 'RETROCEDIENDO',
    Movement.left => 'GIRO IZQUIERDA',
    Movement.right => 'GIRO DERECHA',
    Movement.stopped => 'DETENIDO',
  };
}
 
class _CommandPanel extends StatelessWidget {
  const _CommandPanel({
    required this.movement,
    required this.enabled,
    required this.onMove,
  });
 
  final Movement movement;
  final bool enabled;
  final ValueChanged<Movement> onMove;
 
  @override
  Widget build(BuildContext context) {
    return HmiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONTROLES DIRECTOS',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Alternativa accesible al joystick',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          _DirectionButton(
            label: 'Adelante',
            icon: Icons.arrow_upward_rounded,
            movement: Movement.forward,
            selected: movement == Movement.forward,
            enabled: enabled,
            onMove: onMove,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DirectionButton(
                  label: 'Izquierda',
                  icon: Icons.arrow_back_rounded,
                  movement: Movement.left,
                  selected: movement == Movement.left,
                  enabled: enabled,
                  onMove: onMove,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DirectionButton(
                  label: 'Derecha',
                  icon: Icons.arrow_forward_rounded,
                  movement: Movement.right,
                  selected: movement == Movement.right,
                  enabled: enabled,
                  onMove: onMove,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DirectionButton(
            label: 'Atrás',
            icon: Icons.arrow_downward_rounded,
            movement: Movement.backward,
            selected: movement == Movement.backward,
            enabled: enabled,
            onMove: onMove,
          ),
          const SizedBox(height: 8),
          _DirectionButton(
            label: 'Stop',
            icon: Icons.stop_rounded,
            movement: Movement.stopped,
            selected: movement == Movement.stopped,
            enabled: enabled,
            onMove: onMove,
            danger: true,
          ),
        ],
      ),
    );
  }
}
 
class _DirectionButton extends StatelessWidget {
  const _DirectionButton({
    required this.label,
    required this.icon,
    required this.movement,
    required this.selected,
    required this.enabled,
    required this.onMove,
    this.danger = false,
  });
 
  final String label;
  final IconData icon;
  final Movement movement;
  final bool selected;
  final bool enabled;
  final ValueChanged<Movement> onMove;
  final bool danger;
 
  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ecoGreen;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: 'Mover $label',
      child: SizedBox(
        height: 51,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: selected ? color.withValues(alpha: .16) : null,
            foregroundColor: selected ? color : AppColors.ink,
            side: BorderSide(color: selected ? color : AppColors.divider),
          ),
          onPressed: enabled ? () => onMove(movement) : null,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
 
