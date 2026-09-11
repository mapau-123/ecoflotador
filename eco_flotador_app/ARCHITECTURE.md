# Arquitectura de ECO FLOTADOR

## Jerarquía de presentación

```text
EcoFlotadorApp
└── EcoFlotadorScope (InheritedNotifier)
    └── MaterialApp
        └── AppShell
            ├── AppBar + estado Bluetooth permanente
            ├── DemoBanner (cuando aplica)
            ├── IndexedStack
            │   ├── HomeScreen
            │   ├── ControlScreen
            │   ├── DataScreen
            │   └── SettingsScreen
            └── NavigationBar
```

## Flujo funcional

```text
Pantallas y widgets
        │
        ▼
EcoFlotadorController (estado y casos de uso)
        │
        ├────────► Esp32Protocol (comandos y parser)
        │
        ├────────► SettingsService (preferencias locales)
        │
        └────────► BluetoothGateway (contrato)
                         │
                         ├── DemoBluetoothGateway
                         └── RealBluetoothGateway (punto de integración)
```

La interfaz solamente observa modelos tipados. No conoce el paquete Bluetooth,
el UUID BLE, el socket Classic ni los detalles del ESP32. Esto permite conservar
las cuatro pantallas al cambiar el transporte.

## Responsabilidades

- `models/`: estado del vehículo, telemetría, dispositivos y configuración.
- `providers/`: estado reactivo y acciones de la aplicación.
- `services/esp32_protocol.dart`: único lugar que conoce `F`, `B`, `L`, `R`,
  `S`, `BELT_ON`, `BELT_OFF`, `BELT_SPEED:n` y el formato de telemetría.
- `services/bluetooth_gateway.dart`: contrato estable de comunicación.
- `services/demo_bluetooth_gateway.dart`: simulador funcional.
- `services/real_bluetooth_gateway.dart`: plantilla para el adaptador físico.
- `screens/`: composición de cada destino principal.
- `widgets/`: HMI reutilizable, joystick, tarjetas, alertas y gráficos.

## Seguridad de operación

- Si el modo demo está apagado y no hay conexión, movimiento y banda quedan
  deshabilitados.
- La pérdida de enlace detiene el estado visual de motores y banda.
- El botón de emergencia manda `S` y `BELT_OFF`.
- Al soltar el joystick se manda `S`.
- Los porcentajes recibidos se limitan al rango 0–100.

## Decisión pendiente para el ESP32

Antes de integrar hardware hay que confirmar si el firmware expondrá:

1. BLE GATT (servicio y características con UUID), o
2. Bluetooth Classic SPP.

Después se selecciona el paquete Flutter correspondiente y se implementan los
cinco métodos de `RealBluetoothGateway`. El controlador y la UI no cambian.
