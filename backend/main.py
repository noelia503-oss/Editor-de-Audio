"""
Servidor FastAPI para procesamiento de audio
Recibe archivos de audio, los procesa y devuelve el resultado
"""

from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import uuid
import shutil
from datetime import datetime
from typing import Optional
from audio_processor import AudioProcessor

# Crear la aplicación FastAPI
app = FastAPI(
    title="API de Edición de Audio",
    description="Backend profesional para procesamiento de audio de guitarra y voz",
    version="1.0.0"
)

# Configurar CORS para permitir peticiones desde Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especifica el dominio de tu app
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Directorios
UPLOAD_DIR = "uploads"
PROCESSED_DIR = "processed"

# Crear directorios si no existen
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(PROCESSED_DIR, exist_ok=True)

# Instanciar el procesador de audio
audio_processor = AudioProcessor()

# Almacenamiento en memoria del historial (en producción usarías una base de datos)
processing_history = []


@app.get("/")
async def root():
    """Endpoint raíz - información del API"""
    return {
        "message": "🎸 API de Edición de Audio para Guitarra y Voz",
        "version": "1.0.0",
        "endpoints": {
            "POST /process-audio": "Procesar un archivo de audio",
            "GET /download/{file_id}": "Descargar audio procesado",
            "GET /history": "Ver historial de procesamiento",
            "GET /health": "Estado del servidor"
        }
    }


@app.get("/health")
async def health():
    """Verifica que el servidor está funcionando"""
    return {"status": "ok", "message": "Servidor funcionando correctamente"}


@app.post("/process-audio")
async def process_audio(
    file: UploadFile = File(..., description="Archivo de audio (WAV, M4A, MP3)"),
    noise_reduction: Optional[float] = Form(0.7, description="Intensidad de reducción de ruido (0.0-1.0)"),
    apply_reverb: Optional[bool] = Form(True, description="Aplicar efecto de reverb")
):
    """
    Procesa un archivo de audio aplicando el pipeline profesional

    Args:
        file: Archivo de audio a procesar
        noise_reduction: Intensidad de reducción de ruido (0.0 a 1.0)
        apply_reverb: Si aplicar reverb o no

    Returns:
        JSON con información del procesamiento y URL de descarga
    """

    # Validar el tipo de archivo
    allowed_extensions = ['.wav', '.m4a', '.mp3', '.aac', '.flac']
    file_ext = os.path.splitext(file.filename)[1].lower()

    if file_ext not in allowed_extensions:
        raise HTTPException(
            status_code=400,
            detail=f"Formato no soportado. Usa: {', '.join(allowed_extensions)}"
        )

    # Validar parámetros
    if not 0.0 <= noise_reduction <= 1.0:
        raise HTTPException(
            status_code=400,
            detail="noise_reduction debe estar entre 0.0 y 1.0"
        )

    try:
        # Generar ID único para este procesamiento
        file_id = str(uuid.uuid4())
        timestamp = datetime.now()

        # Guardar el archivo subido
        input_filename = f"{file_id}_original{file_ext}"
        input_path = os.path.join(UPLOAD_DIR, input_filename)

        with open(input_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        print(f"\n{'='*60}")
        print(f"🎵 NUEVO PROCESAMIENTO: {file.filename}")
        print(f"📁 ID: {file_id}")
        print(f"🔧 Configuración:")
        print(f"   - Reducción de ruido: {noise_reduction*100:.0f}%")
        print(f"   - Reverb: {'Sí' if apply_reverb else 'No'}")
        print(f"{'='*60}\n")

        # Ruta del archivo procesado
        output_filename = f"{file_id}_processed.wav"
        output_path = os.path.join(PROCESSED_DIR, output_filename)

        # Procesar el audio
        result = audio_processor.process_audio(
            input_path=input_path,
            output_path=output_path,
            noise_reduction_strength=noise_reduction,
            apply_reverb=apply_reverb
        )

        # Obtener tamaño de los archivos
        original_size = os.path.getsize(input_path)
        processed_size = os.path.getsize(output_path)

        # Crear registro del procesamiento
        processing_record = {
            "id": file_id,
            "original_filename": file.filename,
            "timestamp": timestamp.isoformat(),
            "duration": result["duration"],
            "sample_rate": result["sample_rate"],
            "settings": {
                "noise_reduction": noise_reduction,
                "apply_reverb": apply_reverb
            },
            "file_sizes": {
                "original_mb": round(original_size / (1024 * 1024), 2),
                "processed_mb": round(processed_size / (1024 * 1024), 2)
            },
            "download_url": f"/download/{file_id}"
        }

        # Guardar en el historial
        processing_history.append(processing_record)

        print(f"\n✅ PROCESAMIENTO COMPLETADO")
        print(f"📦 Tamaño original: {processing_record['file_sizes']['original_mb']} MB")
        print(f"📦 Tamaño procesado: {processing_record['file_sizes']['processed_mb']} MB")
        print(f"{'='*60}\n")

        return JSONResponse(content={
            "success": True,
            "message": "Audio procesado correctamente",
            "data": processing_record
        })

    except Exception as e:
        print(f"\n❌ ERROR durante el procesamiento: {str(e)}\n")
        raise HTTPException(status_code=500, detail=f"Error procesando el audio: {str(e)}")


@app.get("/download/{file_id}")
async def download_audio(file_id: str):
    """
    Descarga un archivo de audio procesado

    Args:
        file_id: ID del archivo procesado

    Returns:
        Archivo de audio procesado
    """
    output_filename = f"{file_id}_processed.wav"
    output_path = os.path.join(PROCESSED_DIR, output_filename)

    if not os.path.exists(output_path):
        raise HTTPException(status_code=404, detail="Archivo no encontrado")

    return FileResponse(
        path=output_path,
        media_type="audio/wav",
        filename=f"audio_procesado_{file_id}.wav"
    )


@app.get("/history")
async def get_history():
    """
    Devuelve el historial de procesamiento

    Returns:
        Lista de todos los procesamientos realizados
    """
    return {
        "success": True,
        "total": len(processing_history),
        "history": processing_history
    }


@app.delete("/clean")
async def clean_files():
    """
    Limpia archivos antiguos (útil para desarrollo)

    Returns:
        Número de archivos eliminados
    """
    deleted_count = 0

    # Limpiar uploads
    for filename in os.listdir(UPLOAD_DIR):
        file_path = os.path.join(UPLOAD_DIR, filename)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
                deleted_count += 1
        except Exception as e:
            print(f"Error eliminando {file_path}: {e}")

    # Limpiar processed
    for filename in os.listdir(PROCESSED_DIR):
        file_path = os.path.join(PROCESSED_DIR, filename)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
                deleted_count += 1
        except Exception as e:
            print(f"Error eliminando {file_path}: {e}")

    # Limpiar historial
    processing_history.clear()

    return {
        "success": True,
        "message": f"Se eliminaron {deleted_count} archivos",
        "deleted": deleted_count
    }


if __name__ == "__main__":
    import uvicorn

    print("\n" + "="*60)
    print("🎸 SERVIDOR DE EDICIÓN DE AUDIO")
    print("="*60)
    print("🚀 Iniciando servidor...")
    print("📡 URL: http://localhost:8000")
    print("📖 Documentación: http://localhost:8000/docs")
    print("="*60 + "\n")

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True  # Recarga automática al cambiar el código
    )
