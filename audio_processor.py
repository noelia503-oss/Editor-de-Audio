"""
Módulo de procesamiento de audio profesional para guitarra y voz
Pipeline: Reducción de ruido -> Compresión -> EQ -> Noise Gate -> Reverb -> Normalización
"""

import numpy as np
import soundfile as sf
import noisereduce as nr
from pedalboard import (
    Pedalboard,
    Compressor,
    NoiseGate,
    LowShelfFilter,
    HighpassFilter,
    Reverb,
    Gain
)
from pydub import AudioSegment
from pydub.effects import normalize
import os
from typing import Tuple


class AudioProcessor:
    """Procesador de audio profesional con pipeline completo"""

    def __init__(self):
        """Inicializa el procesador con configuración por defecto"""
        self.sample_rate = 44100

    def process_audio(
        self,
        input_path: str,
        output_path: str,
        noise_reduction_strength: float = 0.7,
        apply_reverb: bool = True
    ) -> dict:
        """
        Procesa un archivo de audio aplicando todo el pipeline profesional

        Args:
            input_path: Ruta del archivo de audio de entrada
            output_path: Ruta donde guardar el audio procesado
            noise_reduction_strength: Intensidad de reducción de ruido (0.0-1.0)
            apply_reverb: Si aplicar reverb o no

        Returns:
            dict con información del procesamiento
        """
        print(f"📂 Cargando audio desde: {input_path}")

        # 1. Cargar el audio
        audio_data, sample_rate = sf.read(input_path)
        self.sample_rate = sample_rate

        # Convertir a mono si es estéreo
        if len(audio_data.shape) > 1:
            audio_data = np.mean(audio_data, axis=1)
            print("🔄 Convertido de estéreo a mono")

        original_duration = len(audio_data) / sample_rate
        print(f"⏱️  Duración: {original_duration:.2f} segundos")
        print(f"🎵 Sample rate: {sample_rate} Hz")

        # 2. REDUCCIÓN DE RUIDO (noisereduce)
        print("\n🔇 PASO 1: Reducción de ruido...")
        audio_data = self._reduce_noise(audio_data, sample_rate, noise_reduction_strength)

        # 3. PIPELINE DE PEDALBOARD (Compresión, EQ, Noise Gate, Reverb)
        print("\n🎛️  PASO 2: Aplicando efectos profesionales...")
        audio_data = self._apply_pedalboard_effects(audio_data, sample_rate, apply_reverb)

        # 4. NORMALIZACIÓN FINAL (pydub)
        print("\n📊 PASO 3: Normalizando volumen...")
        audio_data = self._normalize_audio(audio_data, sample_rate, output_path)

        print(f"\n✅ Audio procesado guardado en: {output_path}")

        return {
            "success": True,
            "duration": original_duration,
            "sample_rate": sample_rate,
            "output_file": output_path,
            "effects_applied": {
                "noise_reduction": True,
                "compression": True,
                "eq": True,
                "noise_gate": True,
                "reverb": apply_reverb,
                "normalization": True
            }
        }

    def _reduce_noise(
        self,
        audio: np.ndarray,
        sample_rate: int,
        strength: float
    ) -> np.ndarray:
        """
        Reduce el ruido de fondo usando spectral gating

        Args:
            audio: Array de audio
            sample_rate: Tasa de muestreo
            strength: Intensidad (0.0-1.0)
        """
        # noisereduce usa spectral gating para eliminar ruidos
        reduced_audio = nr.reduce_noise(
            y=audio,
            sr=sample_rate,
            prop_decrease=strength,  # Proporción de reducción
            stationary=True,  # Para ruidos constantes (ventilador, aire acondicionado)
        )
        print(f"   ✓ Ruido reducido (intensidad: {strength*100:.0f}%)")
        return reduced_audio

    def _apply_pedalboard_effects(
        self,
        audio: np.ndarray,
        sample_rate: int,
        apply_reverb: bool
    ) -> np.ndarray:
        """
        Aplica la cadena de efectos profesionales usando Pedalboard de Spotify

        Pipeline:
        1. HighPassFilter: Elimina frecuencias muy bajas (ruido de manejo del micro)
        2. Compressor: Iguala el volumen entre partes fuertes y suaves
        3. NoiseGate: Silencia el ruido entre acordes/frases
        4. LowShelfFilter: Da cuerpo a la guitarra
        5. Gain: Ajusta el volumen de salida
        6. Reverb (opcional): Añade espacio natural
        """

        # Crear la cadena de efectos
        board = Pedalboard([
            # 1. Filtro pasa-altos: elimina frecuencias por debajo de 80Hz
            #    (ruido de manipulación, rumble)
            HighpassFilter(cutoff_frequency_hz=80),

            # 2. Compresor: iguala el rango dinámico
            #    threshold: nivel donde empieza a comprimir (-16dB)
            #    ratio: cuánto comprime (4:1 = por cada 4dB, solo sube 1dB)
            #    attack_ms: qué tan rápido actúa (5ms = rápido)
            #    release_ms: qué tan rápido suelta (100ms)
            Compressor(
                threshold_db=-16,
                ratio=4,
                attack_ms=5,
                release_ms=100
            ),

            # 3. Noise Gate: silencia el ruido cuando no hay señal
            #    threshold: nivel mínimo para dejar pasar audio (-40dB)
            #    ratio: cuánto atenúa el ruido (10:1 = casi silencio total)
            NoiseGate(
                threshold_db=-40,
                ratio=10,
                attack_ms=1,
                release_ms=100
            ),

            # 4. EQ: Low Shelf a 400Hz (+3dB) para dar cuerpo a la guitarra
            #    Realza las frecuencias bajas-medias donde está el cuerpo del sonido
            LowShelfFilter(
                cutoff_frequency_hz=400,
                gain_db=3,
                q=0.707
            ),

            # 5. Ganancia: ajuste final de volumen (+2dB)
            Gain(gain_db=2),
        ])

        # Añadir reverb si está activado
        if apply_reverb:
            board.append(
                Reverb(
                    room_size=0.3,      # Sala pequeña/mediana
                    damping=0.5,        # Amortiguación media
                    wet_level=0.15,     # 15% de señal con reverb
                    dry_level=0.85,     # 85% de señal original
                    width=0.5,          # Ancho estéreo
                )
            )

        # Aplicar todos los efectos
        print("   ✓ Filtro pasa-altos (80Hz)")
        print("   ✓ Compresor (-16dB threshold, ratio 4:1)")
        print("   ✓ Noise Gate (-40dB threshold)")
        print("   ✓ Ecualización (Low Shelf 400Hz +3dB)")
        print("   ✓ Ganancia (+2dB)")
        if apply_reverb:
            print("   ✓ Reverb (room size 0.3, wet 15%)")

        processed_audio = board(audio, sample_rate)

        return processed_audio

    def _normalize_audio(
        self,
        audio: np.ndarray,
        sample_rate: int,
        output_path: str
    ) -> np.ndarray:
        """
        Normaliza el audio al máximo volumen sin distorsión

        Args:
            audio: Array de audio
            sample_rate: Tasa de muestreo
            output_path: Ruta de salida
        """
        # Guardar temporalmente como WAV
        temp_path = output_path.replace('.wav', '_temp.wav')
        sf.write(temp_path, audio, sample_rate)

        # Cargar con pydub y normalizar
        audio_segment = AudioSegment.from_wav(temp_path)
        normalized = normalize(audio_segment)

        # Exportar el resultado final
        normalized.export(output_path, format='wav')

        # Eliminar archivo temporal
        if os.path.exists(temp_path):
            os.remove(temp_path)

        print(f"   ✓ Audio normalizado al máximo volumen sin distorsión")

        # Cargar el audio normalizado para devolverlo
        final_audio, _ = sf.read(output_path)
        return final_audio


def test_processor():
    """Función de prueba del procesador"""
    processor = AudioProcessor()

    # Crear un audio de prueba (tono de 440Hz - La)
    duration = 3  # segundos
    sample_rate = 44100
    t = np.linspace(0, duration, int(sample_rate * duration))

    # Generar tono con algo de ruido
    signal = np.sin(2 * np.pi * 440 * t) * 0.3
    noise = np.random.normal(0, 0.05, signal.shape)
    test_audio = signal + noise

    # Guardar audio de prueba
    test_input = "test_input.wav"
    sf.write(test_input, test_audio, sample_rate)

    print("🎸 Procesador de Audio - Prueba")
    print("=" * 50)

    # Procesar
    result = processor.process_audio(
        test_input,
        "test_output.wav",
        noise_reduction_strength=0.7,
        apply_reverb=True
    )

    print("\n" + "=" * 50)
    print("📊 Resultado:", result)

    # Limpiar
    if os.path.exists(test_input):
        os.remove(test_input)


if __name__ == "__main__":
    test_processor()
