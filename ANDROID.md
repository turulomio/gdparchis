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

# Descargar Platform Tools, SDK Platform 34 y Build-Tools 34
sdkmanager --sdk_root=$HOME/.android/sdk "platform-tools" "platforms;android-34" "build-tools;34.0.0"
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

El paquete ejecutable resultante se generará en el directorio `dist/Android/gdparchis.apk`.
