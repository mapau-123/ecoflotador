# ECO FLOTADOR · HMI móvil

Aplicación Flutter diseñada específicamente para controlar y monitorear el
vehículo mecatrónico ECO FLOTADOR, recolector manual de residuos sólidos en la
superficie del agua de la Bahía de Cartagena.

La entrega es una aplicación navegable e interactiva con modo demostración
completo. No agrega GPS, mapas, cámaras, autonomía, inteligencia artificial ni
sensores no solicitados.

## Funciones incluidas

- Dashboard profesional con identidad marina, ecológica y tecnológica.
- Navegación inferior: Inicio, Control, Datos y Configuración.
- Joystick táctil y controles directos accesibles.
- Avanzar, retroceder, izquierda, derecha y detener.
- STOP de emergencia que detiene motores y banda.
- Inicio, detención y velocidad de la banda recolectora.
- Batería en porcentaje y voltaje.
- Nivel y estados del recipiente: Normal, Atención y Lleno.
- Estados de motores, banda y Bluetooth.
- Alertas por batería baja, recipiente y pérdida de conexión.
- Controles bloqueados al perder Bluetooth fuera del modo demo.
- Búsqueda, conexión y desconexión simuladas.
- Telemetría simulada con actualización automática.
- Botones para demostrar alertas ante el jurado.
- Persistencia local de umbrales y preferencias.
- Animaciones de progreso, estados, conexión, joystick y alertas.
- Diseño responsive para teléfonos y tabletas Android.
- Semántica y alternativa al joystick para accesibilidad.

## Protocolo ESP32

Comandos de salida:

```text
F
B
L
R
S
BELT_ON
BELT_OFF
BELT_SPEED:50
```

Paquete de entrada:

```text
BAT:85 VOLT:12.4 BIN:68 MOTOR:ON BELT:OFF
```

`Esp32Protocol` concentra esta traducción. Los paquetes también pueden llegar
de forma parcial, por ejemplo `BAT:85` o `BIN:68`.

## Ejecutar en Windows

Requisitos:

- Flutter 3.44 o posterior con Dart 3.12.
- Android Studio, Android SDK y un emulador o teléfono Android.
- VS Code o Android Studio con el complemento Flutter.

Abra PowerShell en la carpeta `eco_flotador_app` y ejecute:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\tool\bootstrap_android.ps1
flutter run
```

El proyecto ya incluye el host Android. El script valida Flutter y ejecuta
dependencias, formato, análisis y pruebas; si el host faltara, lo regeneraría.

Para crear un APK:

```powershell
flutter build apk --release
```

El archivo generado quedará en:

```text
build\app\outputs\flutter-apk\app-release.apk
```

## Integración real con el ESP32

`main.dart` ya usa `RealBluetoothGateway`, que habla BLE de verdad con el
firmware en `firmware/eco_flotador_esp32/` mediante el paquete
[`universal_ble`](https://pub.dev/packages/universal_ble) (funciona igual en
Android nativo y en la versión web vía Web Bluetooth).

Estado real del hardware:

- **Propulsión (2 motores, TB6612FNG): real.** La app envía `"x,y"`
  (joystick, -100 a 100) a la characteristic BLE del ESP32, tal como espera
  `procesarJoystick()` en el firmware.
- **Banda recolectora: pendiente.** Aún no hay motor físico; los comandos
  `BELT_ON/OFF/SPEED` se siguen generando en la UI pero el firmware los
  ignora de forma segura (no rompe nada). El punto de extensión ya está
  comentado en el `.ino`.
- **Telemetría (batería, nivel del recipiente): pendiente.** Sin sensores
  aún, el ESP32 no envía notificaciones BLE, así que esos indicadores no se
  actualizarán hasta que agregues los sensores y actives el bloque
  comentado `enviarTelemetria()` en el firmware.

Detalle importante: el firmware detiene los motores si no recibe un mensaje
en 800 ms (failsafe de seguridad). El controlador (`EcoFlotadorController`)
ya reenvía el último comando cada 300 ms mientras el joystick está
sostenido, para que el movimiento no se corte solo.

Web Bluetooth (necesario para la versión web) solo funciona en navegadores
basados en Chromium (Chrome, Edge, Opera — no Safari ni Firefox) y requiere
HTTPS, que GitHub Pages ya provee.

El modo demostración (`DemoBluetoothGateway`) se mantiene disponible como
opción alternable en Configuración para presentaciones sin el bote físico a
la mano.

## Ejecutar la versión web (una sola vez)

Esta carpeta todavía no incluye la carpeta `web/` porque este entorno no
tiene el SDK de Flutter instalado para generarla. Hazlo una vez, en tu
máquina, dentro de `eco_flotador_app`:

```powershell
flutter create --platforms=web .
flutter pub get
flutter run -d chrome
```

Esto agrega `web/index.html` y los íconos ya adaptados a tu versión exacta
de Flutter (3.44). No hace falta tocar nada más: `RealBluetoothGateway` ya
funciona igual en Android y en Chrome/Edge vía Web Bluetooth.

Para compilar la versión estática que se publica en GitHub Pages:

```powershell
flutter build web --release
```

El flujo de GitHub Actions (`.github/workflows/deploy-web.yml`, en la raíz
del repositorio) hace esto automáticamente en cada push a `main` y publica
el resultado en GitHub Pages.

## Pruebas

```powershell
flutter analyze
flutter test
```

Se incluyen pruebas para:

- Codificación de comandos.
- Interpretación de telemetría completa y parcial.
- Calibración configurable de batería.
- Navegación por las cuatro secciones.

## Recorrido de demostración

1. Presente el dashboard y la ilustración del prototipo.
2. Entre en Control, mueva el joystick y active la banda.
3. Cambie la velocidad con el slider y los botones rápidos.
4. Abra Datos y simule batería baja o recipiente lleno.
5. En Configuración, muestre la búsqueda Bluetooth y los umbrales.
6. Desactive Modo demostración para evidenciar el bloqueo seguro sin conexión.

## Verificación realizada

La entrega fue validada con Flutter 3.44.9 y Dart 3.12.2:

```text
flutter analyze  → Sin observaciones
flutter test     → 5 pruebas aprobadas
```

La compilación del APK no se ejecutó en este entorno porque no dispone de
Android SDK. El host Android, el manifiesto, los permisos Bluetooth y el
registro del plugin de preferencias sí están incluidos. En un equipo con
Android Studio instalado puede compilarse con:

```powershell
flutter build apk --release
```
