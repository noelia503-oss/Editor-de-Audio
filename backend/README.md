# 🎸 Backend de Edición de Audio para Guitarra y Voz

Backend profesional construido con FastAPI para procesar audio de guitarra y voz con efectos de estudio.

## 🔧 Pipeline de Procesamiento

El audio pasa por estos pasos en orden:

1. **Reducción de Ruido** → `noisereduce` - Elimina ruido de fondo (ventiladores, ambiente)
2. **Filtro Pasa-Altos** → `pedalboard` - Elimina frecuencias muy bajas (rumble)
3. **Compresor** → `pedalboard` - Iguala el volumen entre partes fuertes y suaves
4. **Noise Gate** → `pedalboard` - Silencia el ruido entre acordes/frases
5. **Ecualización** → `pedalboard` - Da cuerpo a la guitarra (Low Shelf 400Hz)
6. **Ganancia** → `pedalboard` - Ajusta el volumen de salida
7. **Reverb** → `pedalboard` - (Opcional) Añade espacio natural
8. **Normalización** → `pydub` - Maximiza el volumen sin distorsión

## 📦 Instalación

```bash
cd backend
pip3 install -r requirements.txt
```

## 🚀 Ejecutar el Servidor

```bash
python3 main.py
```

El servidor estará disponible en:
- **API**: http://localhost:8000
- **Documentación interactiva**: http://localhost:8000/docs

## 📡 Endpoints

### `POST /process-audio`
Procesa un archivo de audio.

**Parámetros:**
- `file` (archivo): Audio a procesar (WAV, M4A, MP3, AAC, FLAC)
- `noise_reduction` (float, opcional): Intensidad de reducción de ruido (0.0-1.0, default: 0.7)
- `apply_reverb` (bool, opcional): Aplicar reverb (default: true)

**Ejemplo con curl:**
```bash
curl -X POST "http://localhost:8000/process-audio" \
  -F "file=@tu_audio.wav" \
  -F "noise_reduction=0.7" \
  -F "apply_reverb=true"
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Audio procesado correctamente",
  "data": {
    "id": "abc-123-def",
    "original_filename": "tu_audio.wav",
    "duration": 30.5,
    "sample_rate": 44100,
    "download_url": "/download/abc-123-def"
  }
}
```

### `GET /download/{file_id}`
Descarga el audio procesado.

```bash
curl -O "http://localhost:8000/download/abc-123-def"
```

### `GET /history`
Ver historial de procesamientos.

```bash
curl "http://localhost:8000/history"
```

### `DELETE /clean`
Limpiar archivos temporales (útil para desarrollo).

```bash
curl -X DELETE "http://localhost:8000/clean"
```

## 🧪 Probar el Procesador

Puedes probar el módulo de procesamiento directamente:

```bash
cd backend
python3 audio_processor.py
```

Esto generará un audio de prueba y lo procesará.

## 📁 Estructura

```
backend/
├── main.py              # Servidor FastAPI
├── audio_processor.py   # Pipeline de procesamiento
├── requirements.txt     # Dependencias
├── uploads/            # Archivos subidos (temporal)
├── processed/          # Archivos procesados
└── README.md           # Este archivo
```

## 🎛️ Configuración del Pipeline

Puedes ajustar los parámetros del procesamiento editando [audio_processor.py](audio_processor.py:91-150):

- **Compresor**: `threshold_db`, `ratio`, `attack_ms`, `release_ms`
- **Noise Gate**: `threshold_db`, `ratio`
- **EQ**: `cutoff_frequency_hz`, `gain_db`
- **Reverb**: `room_size`, `wet_level`, `dry_level`

## 🐛 Solución de Problemas

### El servidor no inicia
```bash
# Asegúrate de tener todas las dependencias
pip3 install -r requirements.txt
```

### Error al procesar audio
Verifica que el formato de audio sea compatible: WAV, M4A, MP3, AAC, FLAC

### Puerto 8000 ocupado
Cambia el puerto en [main.py](main.py:255):
```python
uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)
```

## 📚 Librerías Utilizadas

- **FastAPI**: Framework web moderno
- **noisereduce**: Reducción de ruido con spectral gating
- **pedalboard**: Efectos de audio profesionales (Spotify)
- **pydub**: Normalización y conversión
- **librosa**: Análisis de audio
- **soundfile**: Lectura/escritura de archivos de audio

## 🎵 Formatos Soportados

**Entrada**: WAV, M4A, MP3, AAC, FLAC
**Salida**: WAV (44.1 kHz, mono)

## ⚡ Próximos Pasos

1. Conectar con la app Flutter
2. Añadir más presets (Vocal, Guitarra Eléctrica, Acústica)
3. Implementar análisis de forma de onda
4. Añadir base de datos para persistencia
5. Desplegar en servidor cloud

---

Hecho con ❤️ para músicos y creadores de contenido
