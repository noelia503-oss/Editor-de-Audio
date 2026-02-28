# 🎸 Editor de Audio Profesional para Guitarra y Voz

App completa de edición de audio con procesamiento profesional de 8 etapas. Backend en Python + FastAPI, Frontend en Flutter para iOS/Android.

## ✨ Características

- 🎙️ **Grabación de audio** desde el micrófono
- 🎛️ **Pipeline profesional** de 8 etapas de procesamiento
- 🌊 **Visualización** de forma de onda en tiempo real
- ⚙️ **Controles ajustables** (reducción de ruido, reverb)
- 🎵 **Reproductor integrado**
- 📤 **Compartir audio** procesado
- 🎨 **Tema oscuro** profesional

## 🏗️ Arquitectura

### Backend (Python + FastAPI)
- Reducción de ruido con `noisereduce`
- Efectos profesionales con `pedalboard` de Spotify
- Normalización con `pydub`
- API REST completa

### Frontend (Flutter)
- App multiplataforma (iOS/Android)
- Interfaz moderna y responsiva
- Comunicación con backend vía HTTP

## 🚀 Instalación en iPhone

### Requisitos Previos
- Mac con Xcode instalado
- iPhone conectado por USB
- Cuenta de Apple (gratuita)

### Paso 1: Clonar el Repositorio
```bash
git clone https://github.com/TU_USUARIO/audio-editor-app.git
cd audio-editor-app
```

### Paso 2: Instalar Backend
```bash
cd backend
pip3 install -r requirements.txt
python3 main.py
```

El backend se ejecutará en `http://localhost:8000`

### Paso 3: Configurar Flutter App

1. **Instalar dependencias:**
```bash
cd audio_editor_app
flutter pub get
```

2. **Configurar URL del backend en tu iPhone:**

Edita `lib/services/api_service.dart` y cambia la URL a la IP de tu Mac:

```dart
// Obtén tu IP con: ifconfig | grep "inet " | grep -v 127.0.0.1
final String baseUrl = 'http://TU_IP_LOCAL:8000';  // Ej: http://192.168.1.100:8000
```

3. **Conecta tu iPhone por USB**

4. **Confía en la computadora** (mensaje en el iPhone)

5. **Ejecuta la app:**
```bash
flutter run
```

6. Selecciona tu iPhone de la lista

¡La app se instalará en tu iPhone! 🎉

## 📱 Uso de la App

1. **Abre la app** en tu iPhone
2. **Presiona el botón naranja** para grabar
3. **Toca guitarra o canta**
4. **Presiona el botón rojo** para detener
5. **Configura parámetros** (opcional)
6. **Presiona "Procesar"**
7. **Reproduce y comparte** tu audio mejorado

## 🎛️ Pipeline de Procesamiento

1. Reducción de ruido (spectral gating)
2. Filtro pasa-altos (80Hz)
3. Compresor dinámico (-16dB, ratio 4:1)
4. Noise Gate (-40dB)
5. Ecualización (Low Shelf 400Hz +3dB)
6. Ganancia (+2dB)
7. Reverb (opcional, room 0.3)
8. Normalización final

## 📖 Documentación

- [PROYECTO_FINALIZADO.md](PROYECTO_FINALIZADO.md) - Resumen completo
- [INICIO_RAPIDO.md](INICIO_RAPIDO.md) - Guía rápida
- [backend/README.md](backend/README.md) - Documentación del backend
- [audio_editor_app/README.md](audio_editor_app/README.md) - Documentación de la app

## 🛠️ Tecnologías

**Backend:**
- Python 3.9+
- FastAPI
- noisereduce
- pedalboard (Spotify)
- pydub, librosa, PyTorch

**Frontend:**
- Flutter 3.x
- Dart
- Material Design

## 📊 Estadísticas

- 4,144 líneas de código
- 27 archivos creados
- 8 etapas de procesamiento
- 5 formatos de audio soportados
- 100% documentado en español

## 🐛 Solución de Problemas

### "No se puede conectar con el servidor"
- Verifica que el backend esté corriendo: `http://localhost:8000/health`
- Asegúrate de usar la IP correcta de tu Mac
- iPhone y Mac deben estar en la misma red WiFi

### "Permiso de micrófono denegado"
- Ve a Configuración → Editor de Audio → Micrófono → Activar

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de código abierto bajo la licencia MIT.

## 👤 Autor

Creado con ❤️ para músicos y creadores de contenido

---

**¿Preguntas?** Lee la documentación completa en [PROYECTO_FINALIZADO.md](PROYECTO_FINALIZADO.md)
