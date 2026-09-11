import 'package:flutter/widgets.dart';

import 'eco_flotador_controller.dart';

class EcoFlotadorScope extends InheritedNotifier<EcoFlotadorController> {
  const EcoFlotadorScope({
    super.key,
    required EcoFlotadorController controller,
    required super.child,
  }) : super(notifier: controller);

  static EcoFlotadorController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<EcoFlotadorScope>();
    assert(scope != null, 'No se encontró EcoFlotadorScope en el árbol.');
    return scope!.notifier!;
  }

  static EcoFlotadorController read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<EcoFlotadorScope>();
    final scope = element?.widget as EcoFlotadorScope?;
    assert(scope != null, 'No se encontró EcoFlotadorScope en el árbol.');
    return scope!.notifier!;
  }
}
