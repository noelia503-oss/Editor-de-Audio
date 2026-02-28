# 🎸 Instrucciones de Uso - Backend de Edición de Audio

## ✅ Estado Actual

El backend está **completamente funcional** y corriendo en:
- **URL**: http://localhost:8000
- **Documentación interactiva**: http://localhost:8000/docs

## 🚀 Cómo Iniciar el Servidor

```bash
cd backend
python3 main.py
```

El servidor se iniciará automáticamente y verás este mensaje:

```
============================================================
🎸 SERVIDOR DE EDICIÓN DE AUDIO
============================================================
🚀 Iniciando servidor...
📡 URL: http://localhost:8000
📖 Documentación: http://localhost:8000/docs
============================================================
```

## 🧪 Cómo Probar el Backend

### Opción 1: Usar la Documentación Interactiva (Recomendado)

1. Abre tu navegador y ve a: **http://localhost:8000/docs**
2. Verás una interfaz de Swagger UI muy bonita
3. Haz clic en **POST /process-audio**
4. Haz clic en **"Try it out"**
5. Sube un archivo de audio (WAV, MP3, M4A, etc.)
6. Ajusta los parámetros si quieres:
   - `noise_reduction`: 0.7 (70% de reducción de ruido)
   - `apply_reverb`: true (para añadir reverb)
7. Haz clic en **"Execute"**
8. ¡Verás la respuesta con el enlace de descarga!

### Opción 2: Usar curl desde la terminal

```bash
# Procesar un audio
curl -X POST "http://localhost:8000/process-audio" \
  -F "file=@/ruta/a/tu/audio.wav" \
  -F "noise_reduction=0.7" \
  -F "apply_reverb=true"
```

Recibirás una respuesta como esta:

```json
{
  "success": true,
  "message": "Audio procesado correctamente",
  "data": {
    "id": "abc-123-def",
    "original_filename": "tu_audio.wav",
    "duration": 30.5,
    "download_url": "/download/abc-123-def"
  }
}
```

Luego descarga el audio procesado:

```bash
curl -O "http://localhost:8000/download/abc-123-def"
```

### Opción 3: Crear un audio de prueba

Si no tienes un audio a mano, el sistema puede crear uno de prueba:

```bash
cd backend
python3 audio_processor.py
```

Esto generará:
- `test_input.wav` - Audio original con ruido
- `test_output.wav` - Audio procesado y limpio

## 📊 Endpoints Disponibles

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/` | GET | Información del API |
| `/health` | GET | Estado del servidor |
| `/process-audio` | POST | Procesar un archivo de audio |
| `/download/{file_id}` | GET | Descargar audio procesado |
| `/history` | GET | Ver historial de procesamientos |
| `/clean` | DELETE | Limpiar archivos temporales |

## 🎛️ Parámetros de Procesamiento

### `noise_reduction` (float)
- **Rango**: 0.0 a 1.0
- **Default**: 0.7
- **Descripción**: Intensidad de reducción de ruido
  - `0.3` = Reducción ligera (para ambientes silenciosos)
  - `0.7` = Reducción media (recomendado)
  - `0.9` = Reducción agresiva (para ambientes muy ruidosos)

### `apply_reverb` (boolean)
- **Default**: true
- **Descripción**: Si añadir efecto de reverb natural
  - `true` = Añade espacio y profundidad
  - `false` = Sonido más seco y directo

## 🔧 Pipeline de Procesamiento

El audio pasa por estos pasos automáticamente:

1. **Reducción de Ruido** → Elimina ruido de fondo (ventiladores, ambiente)
2. **Filtro Pasa-Altos (80Hz)** → Elimina frecuencias muy bajas
3. **Compresor** → Iguala el volumen entre partes fuertes y suaves
4. **Noise Gate** → Silencia el ruido entre acordes/frases
5. **Ecualización (400Hz)** → Da cuerpo a la guitarra
6. **Ganancia (+2dB)** → Ajusta el volumen
7. **Reverb (opcional)** → Añade espacio natural
8. **Normalización** → Maximiza el volumen sin distorsión

## 📁 Estructura de Archivos

```
backend/
├── main.py                 # Servidor FastAPI ✅
├── audio_processor.py      # Pipeline de procesamiento ✅
├── requirements.txt        # Dependencias instaladas ✅
├── uploads/               # Archivos subidos (temporal)
├── processed/             # Archivos procesados
├── README.md              # Documentación técnica
└── INSTRUCCIONES.md       # Este archivo
```

## 🎵 Formatos Soportados

**Entrada** (lo que puedes subir):
- WAV (recomendado)
- MP3
- M4A
- AAC
- FLAC

**Salida** (lo que recibes):
- WAV (44.1 kHz, mono, normalizado)

## 🐛 Solución de Problemas

### Error: "Couldn't find ffmpeg"
Este es solo un warning, no afecta el funcionamiento. El backend funciona perfectamente sin ffmpeg para archivos WAV.

Si quieres eliminar el warning, instala ffmpeg:
```bash
brew install ffmpeg
```

### Error: Puerto 8000 ya en uso
Si el puerto está ocupado, cambia el puerto en [main.py](main.py:255):
```python
uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)
```

### Error: ModuleNotFoundError
Reinstala las dependencias:
```bash
pip3 install -r requirements.txt
```

## 📝 Logs del Servidor

Cuando procesas un audio, verás logs detallados:

```
============================================================
🎵 NUEVO PROCESAMIENTO: mi_guitarra.wav
📁 ID: abc-123-def
🔧 Configuración:
   - Reducción de ruido: 70%
   - Reverb: Sí
============================================================

📂 Cargando audio desde: uploads/abc-123-def_original.wav
🔄 Convertido de estéreo a mono
⏱️  Duración: 30.45 segundos
🎵 Sample rate: 44100 Hz

🔇 PASO 1: Reducción de ruido...
   ✓ Ruido reducido (intensidad: 70%)

🎛️  PASO 2: Aplicando efectos profesionales...
   ✓ Filtro pasa-altos (80Hz)
   ✓ Compresor (-16dB threshold, ratio 4:1)
   ✓ Noise Gate (-40dB threshold)
   ✓ Ecualización (Low Shelf 400Hz +3dB)
   ✓ Ganancia (+2dB)
   ✓ Reverb (room size 0.3, wet 15%)

📊 PASO 3: Normalizando volumen...
   ✓ Audio normalizado al máximo volumen sin distorsión

✅ Audio procesado guardado en: processed/abc-123-def_processed.wav

✅ PROCESAMIENTO COMPLETADO
📦 Tamaño original: 2.5 MB
📦 Tamaño procesado: 2.3 MB
============================================================
```

## 🎯 Próximos Pasos

1. ✅ **Backend funcional** - COMPLETADO
2. 🔄 **Crear app Flutter** - Siguiente paso
3. 🔄 **Conectar frontend con backend**
4. 🔄 **Añadir visualización de forma de onda**
5. 🔄 **Implementar historial en la app**

## 💡 Tips

- **Para desarrollo**: El servidor tiene auto-reload, cualquier cambio en el código reinicia automáticamente
- **Documentación interactiva**: http://localhost:8000/docs es tu mejor amigo
- **Historial**: Ve todos los procesamientos en http://localhost:8000/history
- **Limpieza**: Usa `curl -X DELETE http://localhost:8000/clean` para limpiar archivos temporales

---

¿Listo para crear la app de Flutter? 📱🎸

