# 🎸 Editor de Audio - App Flutter

App móvil profesional para grabar, procesar y editar audio de guitarra y voz con efectos de estudio.

## ✨ Características

- 🎙️ **Grabación de audio** desde el micrófono del dispositivo
- 🎛️ **Procesamiento profesional** con backend Python
- 🌊 **Visualización de forma de onda** en tiempo real
- ⚙️ **Controles ajustables** (reducción de ruido, reverb)
- 🎵 **Reproductor integrado** para escuchar el resultado
- 📤 **Compartir audio** procesado
- 🎨 **Tema oscuro** con acentos naranja/ámbar

## 🏗️ Arquitectura

```
audio_editor_app/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── models/
│   │   └── audio_record.dart        # Modelo de datos
│   ├── services/
│   │   ├── api_service.dart         # Comunicación con backend
│   │   └── audio_recorder_service.dart  # Grabación de audio
│   ├── screens/
│   │   ├── recording_screen.dart    # Pantalla de grabación
│   │   └── playback_screen.dart     # Pantalla de reproducción
│   └── widgets/
│       └── waveform_painter.dart    # Visualización de onda
└── pubspec.yaml                     # Dependencias
```

## 📦 Dependencias

- **record**: Grabación de audio
- **audioplayers**: Reproducción de audio
- **dio**: Cliente HTTP para API
- **share_plus**: Compartir archivos
- **permission_handler**: Permisos del dispositivo
- **path_provider**: Acceso al sistema de archivos

## 🚀 Instalación

### 1. Instalar Flutter

Si no tienes Flutter instalado, sigue la guía en [INSTALAR_FLUTTER.md](../INSTALAR_FLUTTER.md)

### 2. Instalar dependencias

```bash
cd audio_editor_app
flutter pub get
```

### 3. Configurar permisos

#### iOS (ios/Runner/Info.plist)
Añade estos permisos:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar audio</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

#### Android (android/app/src/main/AndroidManifest.xml)
Añade estos permisos:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### 4. Configurar la URL del backend

Edita [lib/services/api_service.dart](lib/services/api_service.dart:19) y configura la URL correcta:

```dart
// Para iOS Simulator
final String baseUrl = 'http://localhost:8000';

// Para Android Emulator
final String baseUrl = 'http://10.0.2.2:8000';

// Para dispositivo físico (usa la IP de tu computadora)
final String baseUrl = 'http://192.168.1.100:8000';
```

**Para obtener tu IP:**
```bash
# macOS/Linux
ifconfig | grep "inet "

# Windows
ipconfig
```

## 🎮 Uso

### 1. Iniciar el backend

Primero, asegúrate de que el backend esté corriendo:

```bash
cd ../backend
python3 main.py
```

### 2. Ejecutar la app

```bash
# En simulador iOS
flutter run -d "iPhone 15 Pro"

# En emulador Android
flutter run -d emulator

# En dispositivo físico
flutter run
```

### 3. Grabar y procesar

1. **Presiona el botón naranja** para empezar a grabar
2. **Habla o toca guitarra** mientras ves la forma de onda
3. **Presiona el botón rojo** para detener
4. **Ajusta configuración** si quieres (opcional)
5. **Presiona "Procesar"** y espera unos segundos
6. **Reproduce el audio** procesado
7. **Comparte** si te gusta el resultado

## 🎛️ Configuración de Procesamiento

### Reducción de Ruido
- **0-30%**: Ligera (ambientes silenciosos)
- **40-70%**: Media (recomendado) ✅
- **80-100%**: Agresiva (ambientes ruidosos)

### Reverb
- **Activado**: Añade espacio y profundidad
- **Desactivado**: Sonido más seco y directo

## 📱 Pantallas

### Pantalla de Grabación
- Visualización de forma de onda en tiempo real
- Contador de duración
- Botón de grabar/detener
- Controles de configuración

### Pantalla de Reproducción
- Información del audio procesado
- Controles de reproducción (play/pause/stop)
- Barra de progreso
- Botón para compartir

## 🐛 Solución de Problemas

### Error: "No se puede conectar con el servidor"

**Solución:**
1. Verifica que el backend esté corriendo: `http://localhost:8000/health`
2. Si usas emulador Android, usa `http://10.0.2.2:8000`
3. Si usas dispositivo físico, asegúrate de estar en la misma red WiFi

### Error: "Permiso de micrófono denegado"

**Solución:**
1. Ve a **Configuración** del dispositivo
2. Busca la app **Editor de Audio**
3. Activa el permiso de **Micrófono**

### La app se cierra al grabar

**Solución:**
1. Verifica que los permisos estén configurados en `Info.plist` (iOS) o `AndroidManifest.xml` (Android)
2. Reinstala la app: `flutter run --uninstall-first`

### No se ve la forma de onda

**Solución:**
- Esto es normal, la visualización empieza después de 1 segundo de grabación

## 📊 Estructura de Datos

### AudioRecord
```dart
{
  "id": "abc-123",
  "original_filename": "recording_123.wav",
  "timestamp": "2026-02-27T14:30:00",
  "duration": 30.5,
  "sample_rate": 44100,
  "settings": {
    "noise_reduction": 0.7,
    "apply_reverb": true
  },
  "file_sizes": {
    "original_mb": 2.5,
    "processed_mb": 2.3
  },
  "download_url": "/download/abc-123",
  "local_path": "/path/to/processed.wav"
}
```

## 🎨 Tema y Colores

- **Background**: `#121212` (Negro oscuro)
- **Cards**: `#1E1E1E` (Gris oscuro)
- **Primary**: `Colors.orange` (Naranja)
- **Accent**: `Colors.amber` (Ámbar)

## 🔧 Desarrollo

### Hot Reload
Durante el desarrollo, los cambios se recargan automáticamente:
- Presiona `r` en la terminal para hot reload
- Presiona `R` para hot restart

### Debug
```bash
flutter run --debug
```

### Release (para producción)
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## 📝 Tareas Pendientes

- [ ] Añadir pantalla de historial de grabaciones
- [ ] Implementar guardado local de configuración
- [ ] Añadir más presets (Vocal, Guitarra Eléctrica, Acústica)
- [ ] Mejorar visualización de forma de onda con datos reales
- [ ] Añadir autenticación de usuario
- [ ] Implementar sincronización en la nube

## 🤝 Contribuir

1. Haz fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 📞 Soporte

Si encuentras algún problema o tienes preguntas:

1. Revisa la sección de **Solución de Problemas**
2. Verifica que el backend esté corriendo
3. Asegúrate de tener los permisos configurados

---

Hecho con ❤️ para músicos y creadores de contenido 🎸🎤
