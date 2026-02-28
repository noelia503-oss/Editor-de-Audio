# 🔐 Configurar Permisos - iOS y Android

Esta guía te ayudará a configurar los permisos necesarios para que la app pueda grabar audio.

---

## 📱 iOS - Configuración de Permisos

### Ubicación del archivo
```
audio_editor_app/ios/Runner/Info.plist
```

### Permisos necesarios

Añade estas líneas dentro del `<dict>` principal:

```xml
<!-- Permiso de micrófono -->
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar tu audio de guitarra y voz</string>

<!-- Soporte para reproducción en segundo plano -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### Archivo completo de ejemplo

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>

    <key>CFBundleDisplayName</key>
    <string>Editor de Audio</string>

    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>

    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <key>CFBundleName</key>
    <string>audio_editor_app</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>

    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>

    <!-- AÑADIR ESTOS PERMISOS -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Necesitamos acceso al micrófono para grabar tu audio de guitarra y voz</string>

    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
    <!-- FIN DE PERMISOS -->

    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>

    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
```

---

## 🤖 Android - Configuración de Permisos

### Ubicación del archivo
```
audio_editor_app/android/app/src/main/AndroidManifest.xml
```

### Permisos necesarios

Añade estas líneas dentro del tag `<manifest>`, antes del tag `<application>`:

```xml
<!-- Permisos necesarios -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                 android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                 android:maxSdkVersion="32" />

<!-- Declarar que usamos micrófono pero no lo requerimos (para tablets sin micro) -->
<uses-feature android:name="android.hardware.microphone" android:required="false"/>
```

### Archivo completo de ejemplo

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.audio_editor_app">

    <!-- AÑADIR ESTOS PERMISOS -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="28" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32" />
    <uses-feature android:name="android.hardware.microphone" android:required="false"/>
    <!-- FIN DE PERMISOS -->

    <application
        android:label="Editor de Audio"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

## ✅ Verificar Permisos

### iOS

1. **Ejecuta la app en simulador:**
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

2. **Cuando presiones grabar**, aparecerá un diálogo pidiendo permiso de micrófono

3. **Acepta el permiso**

4. Si no aparece el diálogo:
   - Elimina la app del simulador
   - Ejecuta: `flutter clean`
   - Vuelve a ejecutar: `flutter run`

### Android

1. **Ejecuta la app en emulador:**
   ```bash
   flutter run -d emulator
   ```

2. **Cuando presiones grabar**, aparecerá un diálogo pidiendo permiso de micrófono

3. **Acepta el permiso**

4. Si no aparece el diálogo:
   ```bash
   # Desinstala la app
   adb uninstall com.example.audio_editor_app

   # Reinstala
   flutter run
   ```

---

## 🔍 Diagnóstico de Problemas

### "Permiso de micrófono denegado"

**iOS:**
1. Ve a **Ajustes** del simulador/dispositivo
2. Busca **Editor de Audio**
3. Activa **Micrófono**

**Android:**
1. Mantén presionado el ícono de la app
2. Toca **Información de la app**
3. Toca **Permisos**
4. Activa **Micrófono**

### "La app se cierra al intentar grabar"

Esto significa que los permisos no están configurados correctamente:

1. **Verifica que los archivos están correctos:**
   - iOS: `ios/Runner/Info.plist`
   - Android: `android/app/src/main/AndroidManifest.xml`

2. **Limpia el proyecto:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Reinstala la app:**
   ```bash
   flutter run --uninstall-first
   ```

### "NSMicrophoneUsageDescription not found"

Este error aparece en iOS si falta el permiso en `Info.plist`:

```bash
# 1. Abre el archivo
open ios/Runner/Info.plist

# 2. Añade el permiso como se muestra arriba

# 3. Reinstala
flutter run --uninstall-first
```

---

## 📝 Notas Importantes

### iOS
- El texto en `NSMicrophoneUsageDescription` es lo que verá el usuario
- Debe explicar claramente por qué necesitas el micrófono
- Apple puede rechazar la app si el texto no es claro

### Android
- `android:maxSdkVersion` limita los permisos a versiones antiguas de Android
- Android 11+ maneja los permisos de almacenamiento de forma diferente
- El permiso `RECORD_AUDIO` es considerado "peligroso" y requiere confirmación del usuario

### Dispositivos Físicos

Si vas a probar en un dispositivo físico:

**iOS:**
1. Necesitas una cuenta de desarrollador de Apple (puede ser gratuita)
2. Configura el signing en Xcode
3. Conecta el iPhone via USB

**Android:**
1. Activa **Opciones de desarrollador** en el dispositivo
2. Activa **Depuración USB**
3. Conecta el dispositivo via USB
4. Acepta el mensaje de confianza

---

## 🚀 Siguiente Paso

Una vez configurados los permisos, ejecuta:

```bash
cd audio_editor_app
flutter pub get
flutter run
```

¡Y tu app estará lista para grabar audio! 🎤🎸

---

## 💡 Ayuda Adicional

Si sigues teniendo problemas:

1. Lee los logs de Flutter:
   ```bash
   flutter run --verbose
   ```

2. Verifica que el backend esté corriendo:
   ```bash
   curl http://localhost:8000/health
   ```

3. Revisa la documentación de la app:
   - [README.md](README.md)
   - [RESUMEN_COMPLETO.md](../RESUMEN_COMPLETO.md)
