# 📱 Guía de Instalación de Flutter

Flutter no está instalado en tu sistema. Aquí tienes las instrucciones para instalarlo en macOS.

## 🍎 Instalación en macOS (ARM - Apple Silicon)

### Opción 1: Instalación con Homebrew (Recomendado)

```bash
# 1. Instalar Flutter
brew install --cask flutter

# 2. Verificar la instalación
flutter doctor

# 3. Aceptar las licencias de Android
flutter doctor --android-licenses
```

### Opción 2: Instalación Manual

```bash
# 1. Descargar Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# 2. Añadir Flutter al PATH
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# 3. Verificar la instalación
flutter doctor
```

## ✅ Verificar la Instalación

Después de instalar, ejecuta:

```bash
flutter doctor
```

Deberías ver algo como:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device
```

## 📱 Configuración para iOS (opcional)

Si quieres compilar para iPhone/iPad:

```bash
# 1. Instalar Xcode desde la App Store
# 2. Instalar las herramientas de línea de comandos
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# 3. Instalar CocoaPods
sudo gem install cocoapods
```

## 🤖 Configuración para Android (opcional)

Si quieres compilar para Android:

```bash
# 1. Instalar Android Studio
brew install --cask android-studio

# 2. Abrir Android Studio y seguir el wizard de instalación
# 3. Instalar Android SDK

# 4. Aceptar licencias
flutter doctor --android-licenses
```

## 🚀 Después de Instalar Flutter

Una vez instalado Flutter, regresa aquí y ejecuta:

```bash
# Navegar a la carpeta del proyecto
cd "/Users/noeliatrujillocarrera/Documents/APPS/Edicion de Audio"

# Crear el proyecto Flutter
flutter create audio_editor_app

# Luego copia los archivos que he preparado
```

## ⏱️ Tiempo Estimado

- **Con Homebrew**: 10-15 minutos
- **Manual**: 15-20 minutos

## 🐛 Problemas Comunes

### "flutter: command not found"
El PATH no está configurado. Cierra y abre una nueva terminal.

### "Android licenses not accepted"
Ejecuta: `flutter doctor --android-licenses` y acepta todo

### Xcode no encontrado
Instala Xcode desde la App Store

---

## 💡 Alternativa: Continuar sin Instalar Flutter

Si no quieres instalar Flutter ahora, puedo:

1. ✅ Crear toda la estructura del proyecto Flutter
2. ✅ Escribir todo el código necesario
3. ✅ Preparar las instrucciones de uso

**Cuando instales Flutter, solo tendrás que ejecutar `flutter pub get` y `flutter run`**

¿Quieres que continúe creando la app de Flutter sin instalarlo ahora? (Responde "sí" y lo haré)
