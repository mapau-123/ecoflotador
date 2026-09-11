# ECO FLOTADOR

Vehículo mecatrónico recolector de residuos sólidos flotantes para la Bahía
de Cartagena, con una app Flutter (Android + Web) que lo controla por
Bluetooth de baja energía (BLE) en tiempo real.

## Estructura del repositorio

```text
eco_flotador_app/   App Flutter (HMI móvil y web)
firmware/            Firmware Arduino del ESP32
.github/workflows/   Despliegue automático a GitHub Pages
```

## Estado del proyecto

| Función                          | Estado                                    |
| --------------------------------- | ------------------------------------------ |
| Conexión BLE real app ↔ ESP32     | ✅ Funcionando                              |
| Propulsión (2 motores, joystick)  | ✅ Real                                     |
| Banda recolectora                 | ⏳ Pendiente de motor físico                |
| Telemetría (batería, recipiente)  | ⏳ Pendiente de sensores                    |
| Modo demostración sin hardware    | ✅ Disponible como interruptor              |
| Versión web publicable en GitHub Pages | ✅ Lista (falta un paso local, ver abajo) |

## Cómo funciona la conexión real

La app usa [`universal_ble`](https://pub.dev/packages/universal_ble), que
habla BLE nativo en Android y usa la **Web Bluetooth API** en la versión
web. Eso impone dos límites que vienen del navegador, no de la app:

- Solo funciona en navegadores basados en **Chromium** (Chrome, Edge,
  Opera). Safari y Firefox no soportan Web Bluetooth.
- Requiere **HTTPS**, que GitHub Pages entrega automáticamente.
- El usuario debe elegir el dispositivo desde un diálogo nativo del
  navegador la primera vez (no se puede conectar en automático sin ese
  gesto, es una restricción de seguridad del propio navegador).

## Poner en marcha el repositorio

1. **Genera la carpeta `web/` una sola vez** (este entorno de desarrollo no
   tiene Flutter instalado para hacerlo por ti):

   ```powershell
   cd eco_flotador_app
   flutter create --platforms=web .
   flutter pub get
   git add web
   ```

2. Sube el repositorio a GitHub (rama `main`).
3. En GitHub, ve a **Settings → Pages** y elige **Source: GitHub Actions**.
4. Cada push a `main` compila la app (`flutter build web`) y la publica en
   `https://<tu-usuario>.github.io/<nombre-del-repo>/` mediante el workflow
   en `.github/workflows/deploy-web.yml`.

Para el ESP32, abre `firmware/eco_flotador_esp32/eco_flotador_esp32.ino` en
Arduino IDE, completa los pines marcados como `XX` con tu cableado real, y
súbelo normalmente.

Ver `eco_flotador_app/README.md` para el detalle completo de la app
(protocolo, pruebas, cómo compilar el APK).
