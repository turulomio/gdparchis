# Configuración de Exportación y Entorno Godot 4.7 (Gentoo)

Este documento detalla la adaptación del proyecto **gdparchis** para **Godot 4.7** en Gentoo Linux, incluyendo el soporte de **Wayland por defecto** y la inclusión de **plantillas de exportación locales dentro del proyecto**.

---

## 1. Configuración de Wayland en Linux

En el archivo [`project.godot`](file:///home/keko/Proyectos/gdparchis/project.godot#L81), dentro de la sección `[display]`, se ha configurado el controlador de pantalla nativo para Linux:

```ini
[display]

window/size/width=1920
window/size/height=1080
window/size/fullscreen=true
display_server/driver.linuxbsd="wayland"
```

* **Comportamiento:** Al ejecutar el proyecto en Linux, Godot utilizará Wayland de forma nativa. En entornos sin compositor Wayland activo, Godot realiza un fallback automático a X11/XWayland.

---

## 2. Plantillas de Exportación Locales (`templates/`)

Para evitar depender de la ubicación global de Godot (`~/.local/share/godot/export_templates/`), las plantillas de exportación están almacenadas directamente dentro del repositorio en el directorio [`templates/`](file:///home/keko/Proyectos/gdparchis/templates/).

### Estructura de `templates/`:

```
templates/
├── linux_release.x86_64 -> /usr/bin/godot
├── linux_debug.x86_64   -> /usr/bin/godot
├── windows_release_x86_64.exe
├── windows_debug_x86_64.exe
├── android_release.apk
└── android_debug.apk
```

* **Linux:** Se utiliza `/usr/bin/godot` enlazado como plantilla de exportación local.
* **Windows:** Se incluyen las plantillas oficiales `windows_release_x86_64.exe` y `windows_debug_x86_64.exe` en `templates/`.
* **Android:** Se incluyen las plantillas oficiales `android_release.apk` y `android_debug.apk` en `templates/`.

---

## 3. Presets de Exportación (`export_presets.cfg`)

Los presets en [`export_presets.cfg`](file:///home/keko/Proyectos/gdparchis/export_presets.cfg) apuntan a la carpeta del proyecto usando la notación `res://`:

### Preset 0 (Linux):
```ini
[preset.0]
name="Linux"
platform="Linux"
export_path="dist/Linux/gdparchis.x86_64"

[preset.0.options]
custom_template/debug="res://templates/linux_debug.x86_64"
custom_template/release="res://templates/linux_release.x86_64"
binary_format/embed_pck=false
```

### Preset 1 (Windows Desktop):
```ini
[preset.1]
name="Windows Desktop"
platform="Windows Desktop"
export_path="dist/Windows/Gdparchis.exe"

[preset.1.options]
custom_template/debug="res://templates/windows_debug_x86_64.exe"
custom_template/release="res://templates/windows_release_x86_64.exe"
```

### Preset 3 (Android):
```ini
[preset.3]
name="Android"
platform="Android"
export_path="dist/Android/gdparchis.apk"

[preset.3.options]
architectures/arm64-v8a=true
architectures/x86_64=true
package/unique_name="org.turulomio.gdparchis"
package/name="gdParchis"
```

* Para consultar la guía detallada de instalación de paquetes Portage en Gentoo Linux y preparación del Android SDK, ver [`ANDROID.md`](file:///home/keko/Proyectos/gdparchis/ANDROID.md).

---

## 4. Script de Gestión (`management.py`)

* **Ejecutar el proyecto en desarrollo:**
  ```bash
  python3 management.py --play
  ```

* **Generar binarios de exportación:**
  ```bash
  python3 management.py --export
  ```

Los ejecutables y archivos `.pck` resultantes se generan en:
* `dist/Linux/gdparchis-<VERSION>.x86_64`
* `dist/Linux/gdparchis-<VERSION>.pck`
* `dist/Windows/gdparchis-<VERSION>.exe`

---

## 5. Estándares de Documentación de Código

* **Documentación de Funciones:** Cada función escrita en los scripts (GDScript o Python) debe incluir un bloque de documentación descriptivo (encabezado/docstring con `##` o `""`) explicando su propósito, parámetros y tipo de retorno.
* **Comentarios Internos:** La implementación interna de las funciones debe estar debidamente comentada paso a paso para explicitar la lógica de desarrollo, algoritmos y decisiones clave de diseño.

---

## 6. Directorios de Almacenamiento Estándar del Usuario (`user://`)

El proyecto utiliza la configuración nativa de directorio de usuario personalizado en [`project.godot`](file:///home/keko/Proyectos/gdparchis/project.godot#L65):

```ini
[application]
config/use_custom_user_dir=true
config/custom_user_dir_name="gdparchis"
```

Esto garantiza que todos los archivos persistentes del usuario (`user://`) se almacenen permanentemente en las ubicaciones estándar del sistema operativo:

* **Linux (Estándar XDG Data):** `~/.local/share/gdparchis/`
* **Windows (AppData Roaming):** `%APPDATA%\gdparchis\` (`C:\Users\<usuario>\AppData\Roaming\gdparchis\`)
* **macOS:** `~/Library/Application Support/gdparchis/`

### Archivos almacenados en el directorio de usuario:
* **Configuración del juego:** `user://gdparchis.cfg` (preferencias de pantalla, idioma, sonido y dificultad).
* **Historial permanente de partidas:** `user://game_history.json` (registro de partidas finalizadas y ganadores).
* **Guardados automáticos y manuales:** `user://saves/` (archivos de partidas guardadas en formato `.json`).

---

## 7. Mantenimiento Obligatorio de Documentación

* **Funcionalidades de Usuario (`USER_MANUAL.md`):** Siempre que una modificación afecte, añada o altere la interacción del usuario, controles, reglas del juego, persistencia, interfaz o flujo visual, se debe actualizar obligatoriamente el archivo [`USER_MANUAL.md`](file:///home/keko/Proyectos/gdparchis/USER_MANUAL.md).
* **Plataforma Android (`ANDROID.md`):** Siempre que un cambio afecte a la configuración de compilación, permisos de exportación, gestos de control táctil o dependencias/herramientas del entorno Android, se debe actualizar obligatoriamente el archivo [`ANDROID.md`](file:///home/keko/Proyectos/gdparchis/ANDROID.md).

