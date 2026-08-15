# Guía de Configuración y Compilación de Android en Gentoo Linux

Este documento detalla la instalación de dependencias en **Gentoo Linux**, la preparación del entorno Android SDK y la exportación de paquetes instalables (`.apk`) para el proyecto **gdparchis**.

---

## 1. Paquetes Necesarios en Gentoo Linux (`portage`)

Para compilar y empaquetar aplicaciones Android en Gentoo Linux, instala los siguientes paquetes desde Portage:

```bash
# 1. Instalar la máquina virtual Java OpenJDK 17
emerge --ask dev-java/openjdk:17

# 2. Configurar OpenJDK 17 como la JVM por defecto del sistema
eselect java-vm set system openjdk-17

# 3. Instalar las herramientas de consola del Android SDK y herramientas de depuración (adb)
emerge --ask android-sdk-cmdline-tools android-tools

```

> **Nota alternativa:** Si prefieres gestionar el SDK a través del IDE completo de Google, puedes instalar `dev-util/android-studio`.

---

## 2. Descarga de Componentes del Android SDK

Con `sdkmanager` (incluido en `dev-util/android-sdk-cmdline-tools-bin`), instala las herramientas de compilación requeridas por Godot 4.7:

```bash
# Crear directorio local del SDK de Android
mkdir -p ~/.android/sdk

# Descargar Platform Tools, SDK Platform 36 y Build-Tools
sdkmanager --sdk_root=$HOME/.android/sdk "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

---

## 3. Generación de la Clave de Firma (`debug.keystore`)

Godot requiere un archivo de firma digital para validar la instalación del paquete en dispositivos Android. Genera el keystore de depuración ejecutando:

```bash
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore ~/.android/debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 10000
```

---

## 4. Configuración en Godot Editor (`Editor Settings`)

Abre el proyecto en el editor de Godot e ingresa a **Editor -> Configuración del Editor (Editor Settings) -> Exportación (Export) -> Android**:

* **Ruta del SDK de Android (`Android SDK Path`):** `/home/<usuario>/.android/sdk`
* **Keystore de depuración (`Debug Keystore`):** `/home/<usuario>/.android/debug.keystore`
* **Usuario del Keystore (`Debug Keystore User`):** `androiddebugkey`
* **Contraseña del Keystore (`Debug Keystore Pass`):** `android`

### Permisos de Red (Internet):
En `export_presets.cfg` (Preset Android), se activan los permisos de red para permitir la comprobación de actualizaciones (`HTTPRequest`):
* `permissions/internet=true`
* `permissions/access_network_state=true`

---

## 5. Compilación y Exportación del Binario (`.apk`)

### Opción A: Mediante el script de gestión (`management.py`)
```bash
python3 management.py --export
```

### Opción B: Mediante línea de comandos headless de Godot
```bash
mkdir -p dist/Android
godot --headless --export-release "Android" dist/Android/gdparchis.apk
```

El paquete ejecutable resultante se generará en el directorio `dist/Android/gdparchis-0.9.99.apk`.

---

## 6. Pruebas y Depuración del APK (`adb` y Emuladores)

### Método A: Instalación mediante `adb` (Dispositivo Físico USB)
1. Activa **Opciones de desarrollador** y **Depuración por USB** en tu dispositivo Android.
2. Conecta el dispositivo vía USB e instala la aplicación ejecutando:
   ```bash
   # Verificar dispositivo conectado
   adb devices

   # Instalar el paquete APK
   adb install -r dist/Android/gdparchis-0.9.99.apk

   # Ejecutar la aplicación de forma remota
   adb shell am start -n org.turulomio.gdparchis/com.godot.game.GodotApp

   # Ver registros de depuración en tiempo real
   adb logcat -s godot
   ```

### Método B: Instalación en Waydroid (Linux Wayland)
Si utilizas **Waydroid** en Gentoo/Linux:
```bash
waydroid app install dist/Android/gdparchis-0.9.99.apk
```

### Método C: Despliegue Directo de un Clic desde Godot Editor
Con tu teléfono conectado por USB y `adb` activo, Godot mostrará un icono de Android en la esquina superior derecha del editor. Al hacer clic, Godot compilará, enviará e iniciará el juego automáticamente en el dispositivo mostrando la consola de depuración en vivo.
