FROM python:3.9-slim

WORKDIR /app

# Copiar requirements
COPY requirements.txt .

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código
COPY main.py .
COPY audio_processor.py .

# Crear carpetas necesarias
RUN mkdir -p uploads processed

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
