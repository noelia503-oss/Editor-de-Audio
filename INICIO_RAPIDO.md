# 🚀 Inicio Rápido - App de Edición de Audio

## ✅ Estado Actual

### 🟢 Backend: FUNCIONANDO
- **URL**: http://localhost:8000
- **Docs**: http://localhost:8000/docs
- **Estado**: ✅ Corriendo y listo para usar

### 🟡 Frontend: LISTO PARA EJECUTAR
- **Ubicación**: `audio_editor_app/`
- **Estado**: ⏳ Requiere instalar Flutter

---

## 📋 ¿Qué se ha Creado?

### Backend (Python + FastAPI) ✅
```
backend/
├── main.py                 # Servidor FastAPI ✅
├── audio_processor.py      # Pipeline de procesamiento ✅
├── requirements.txt        # Dependencias instaladas ✅
├── uploads/               # Carpeta de subidas ✅
├── processed/             # Audios procesados ✅
└── Documentación completa ✅
```

**Pipeline profesional de 8 etapas:**
1. Reducción de ruido
2. Filtro pasa-altos
3. Compresor
4. Noise Gate
5. Ecualización
6. Ganancia
7. Reverb (opcional)
8. Normalización

### Frontend (Flutter) ✅
```
audio_editor_app/
├── lib/
│   ├── main.dart              # App principal ✅
│   ├── screens/               # Pantallas ✅
│   ├── services/              # Servicios ✅
│   ├── models/                # Modelos de datos ✅
│   └── widgets/               # Componentes ✅
└── pubspec.yaml               # Configuración ✅
```

**Características:**
- 🎙️ Grabación de audio
- 🌊 Visualización de forma de onda
- ⚙️ Controles ajustables
- 🎵 Reproductor integrado
- 📤 Compartir audio
- 🎨 Tema oscuro

---

## 🎯 Opción 1: Probar el Backend AHORA (Sin Flutter)

### 1. Abrir Documentación Interactiva
```
http://localhost:8000/docs
```

### 2. Probar Procesamiento de Audio

1. En la documentación, haz clic en **`POST /process-audio`**
2. Haz clic en **"Try it out"**
3. Haz clic en **"Choose File"** y sube un audio
4. Configura parámetros (opcional):
   - `noise_reduction`: 0.7
   - `apply_reverb`: true
5. Haz clic en **"Execute"**
6. ¡Verás el procesamiento en tiempo real en la terminal!

### 3. Descargar Audio Procesado

1. Copia el `id` de la respuesta
2. Ve a **`GET /download/{file_id}`**
3. Pega el `id` y ejecuta
4. Descarga tu audio procesado

---

## 🎯 Opción 2: Ejecutar la App Flutter

### Paso 1: Instalar Flutter (10 minutos)

```bash
# macOS con Homebrew
brew install --cask flutter

# Verificar instalación
flutter doctor
```

**Guía detallada:** [INSTALAR_FLUTTER.md](INSTALAR_FLUTTER.md)

### Paso 2: Configurar el Proyecto

```bash
cd audio_editor_app
flutter pub get
```

### Paso 3: Configurar URL del Backend

Edita `audio_editor_app/lib/services/api_service.dart` línea 19:

```dart
// Para iOS Simulator
final String baseUrl = 'http://localhost:8000';

// Para Android Emulator
final String baseUrl = 'http://10.0.2.2:8000';

// Para dispositivo físico (reemplaza con tu IP)
final String baseUrl = 'http://192.168.1.X:8000';
```

**Para saber tu IP:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### Paso 4: Configurar Permisos

**Guía completa:** [audio_editor_app/CONFIGURAR_PERMISOS.md](audio_editor_app/CONFIGURAR_PERMISOS.md)

**iOS** - Edita `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar audio</string>
```

**Android** - Edita `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Paso 5: Ejecutar la App

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en iOS Simulator
flutter run -d "iPhone 15 Pro"

# Ejecutar en Android Emulator
flutter run -d emulator

# O simplemente
flutter run
```

---

## 📖 Documentación Disponible

### Backend
- 📘 [backend/README.md](backend/README.md) - Documentación técnica
- 📗 [backend/INSTRUCCIONES.md](backend/INSTRUCCIONES.md) - Guía de uso
- 🌐 http://localhost:8000/docs - Documentación interactiva

### Frontend
- 📘 [audio_editor_app/README.md](audio_editor_app/README.md) - Docs de la app
- 🔐 [audio_editor_app/CONFIGURAR_PERMISOS.md](audio_editor_app/CONFIGURAR_PERMISOS.md) - Permisos

### General
- 📕 [RESUMEN_COMPLETO.md](RESUMEN_COMPLETO.md) - Resumen del proyecto
- 📙 [INSTALAR_FLUTTER.md](INSTALAR_FLUTTER.md) - Instalar Flutter
- 🚀 Este archivo - Inicio rápido

---

## 🎵 Cómo Usar la App (Una vez instalada)

1. **Abre la app** en tu dispositivo/simulador
2. **Presiona el botón naranja** (micrófono) para grabar
3. **Toca tu guitarra o canta** mientras ves la forma de onda
4. **Presiona el botón rojo** para detener
5. **Ajusta configuración** si quieres:
   - Reducción de ruido (0-100%)
   - Reverb (activado/desactivado)
6. **Presiona "Procesar"** y espera unos segundos
7. **Reproduce tu audio** procesado
8. **Comparte** si te gusta el resultado

---

## 🎛️ Configuración Recomendada

### Para Guitarra Acústica
- Reducción de ruido: **60-70%**
- Reverb: **Activado**

### Para Voz
- Reducción de ruido: **70-80%**
- Reverb: **Activado**

### Para Guitarra Eléctrica
- Reducción de ruido: **50-60%**
- Reverb: **Desactivado** o ligero

### Para Ambiente Ruidoso
- Reducción de ruido: **80-90%**
- Reverb: **Desactivado**

---

## 🐛 Problemas Comunes

### "No se puede conectar con el servidor"

**Solución:**
```bash
# 1. Verifica que el backend esté corriendo
curl http://localhost:8000/health

# 2. Si no responde, reinicia el servidor
cd backend
python3 main.py
```

### "Permiso de micrófono denegado"

**Solución:**
1. Ve a Configuración del dispositivo
2. Busca "Editor de Audio"
3. Activa el permiso de Micrófono

### "Flutter command not found"

**Solución:**
```bash
# Instalar Flutter
brew install --cask flutter

# Reiniciar terminal
source ~/.zshrc
```

---

## 📊 Archivos Creados (17 archivos)

```
✅ Backend (7 archivos)
   - main.py
   - audio_processor.py
   - requirements.txt
   - README.md
   - INSTRUCCIONES.md
   + 2 carpetas (uploads, processed)

✅ Frontend (10 archivos)
   - main.dart
   - audio_record.dart
   - api_service.dart
   - audio_recorder_service.dart
   - recording_screen.dart
   - playback_screen.dart
   - waveform_painter.dart
   - pubspec.yaml
   - README.md
   - CONFIGURAR_PERMISOS.md

✅ Documentación (3 archivos)
   - RESUMEN_COMPLETO.md
   - INSTALAR_FLUTTER.md
   - INICIO_RAPIDO.md (este archivo)
```

---

## 🎯 Siguiente Paso

### Si quieres probar el backend YA:
```
👉 Abre: http://localhost:8000/docs
```

### Si quieres usar la app móvil:
```bash
👉 brew install --cask flutter
👉 cd audio_editor_app
👉 flutter run
```

---

## 💡 Consejos Finales

- 🎧 **Usa auriculares** al grabar para evitar retroalimentación
- 🔇 **Graba en ambiente silencioso** para mejores resultados
- ⚙️ **Experimenta con los parámetros** para encontrar tu sonido ideal
- 📖 **Lee la documentación** si tienes dudas
- 🐛 **Revisa los logs** si algo no funciona

---

## 🎉 ¡Listo!

Tienes todo lo necesario para:
- ✅ Grabar audio profesional
- ✅ Procesarlo con efectos de estudio
- ✅ Compartirlo con quien quieras

**¡Disfruta tu app de edición de audio!** 🎸🎤✨

---

## 📞 ¿Necesitas Ayuda?

1. Lee el [RESUMEN_COMPLETO.md](RESUMEN_COMPLETO.md)
2. Revisa la documentación específica en cada carpeta
3. Verifica que el backend esté corriendo
4. Comprueba los logs de la terminal

¡Buena suerte y a crear música increíble! 🎵
