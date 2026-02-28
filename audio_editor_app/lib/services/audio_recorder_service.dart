import 'dart:io';
import 'dart:async';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para grabar audio desde el micrófono del dispositivo
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  Timer? _durationTimer;
  Duration _recordingDuration = Duration.zero;

  /// Stream para escuchar la duración de la grabación
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  Stream<Duration> get durationStream => _durationController.stream;

  /// Verifica y solicita permisos de micrófono
  Future<bool> checkPermissions() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      print('✅ Permiso de micrófono concedido');
      return true;
    }

    if (status.isDenied) {
      print('⚠️ Solicitando permiso de micrófono...');
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        print('✅ Permiso concedido');
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      print('❌ Permiso denegado permanentemente. Abre la configuración.');
      await openAppSettings();
    }

    return false;
  }

  /// Verifica si hay una grabación en progreso
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Inicia la grabación de audio
  ///
  /// Retorna la ruta del archivo donde se está grabando
  Future<String?> startRecording() async {
    try {
      // Verificar permisos
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        throw Exception('No hay permiso para grabar audio');
      }

      // Verificar si ya está grabando
      if (await _recorder.isRecording()) {
        print('⚠️ Ya hay una grabación en progreso');
        return null;
      }

      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/recording_$timestamp.wav';

      print('🎙️ Iniciando grabación...');

      // Configurar y empezar grabación
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100, // CD quality
          bitRate: 128000,
          numChannels: 1, // Mono
        ),
        path: _currentRecordingPath!,
      );

      // Iniciar contador de duración
      _recordingDuration = Duration.zero;
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        _durationController.add(_recordingDuration);
      });

      print('✅ Grabación iniciada: $_currentRecordingPath');
      return _currentRecordingPath;
    } catch (e) {
      print('❌ Error iniciando grabación: $e');
      return null;
    }
  }

  /// Detiene la grabación de audio
  ///
  /// Retorna el archivo File con la grabación
  Future<File?> stopRecording() async {
    try {
      if (!await _recorder.isRecording()) {
        print('⚠️ No hay grabación activa');
        return null;
      }

      print('⏹️ Deteniendo grabación...');

      // Detener la grabación
      final path = await _recorder.stop();

      // Detener el timer
      _durationTimer?.cancel();
      _durationTimer = null;

      if (path != null && await File(path).exists()) {
        final file = File(path);
        final fileSize = await file.length();
        final duration = _recordingDuration;

        print('✅ Grabación detenida');
        print('   📁 Archivo: $path');
        print('   📊 Tamaño: ${(fileSize / 1024).toStringAsFixed(2)} KB');
        print('   ⏱️ Duración: ${duration.inSeconds} segundos');

        _currentRecordingPath = null;
        _recordingDuration = Duration.zero;

        return file;
      } else {
        print('❌ Error: archivo de grabación no encontrado');
        return null;
      }
    } catch (e) {
      print('❌ Error deteniendo grabación: $e');
      return null;
    }
  }

  /// Pausa la grabación (si está soportado)
  Future<void> pauseRecording() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.pause();
        _durationTimer?.cancel();
        print('⏸️ Grabación pausada');
      }
    } catch (e) {
      print('❌ Error pausando grabación: $e');
    }
  }

  /// Reanuda la grabación pausada
  Future<void> resumeRecording() async {
    try {
      if (await _recorder.isPaused()) {
        await _recorder.resume();

        // Reiniciar timer
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + timer.tick);
          _durationController.add(_recordingDuration);
        });

        print('▶️ Grabación reanudada');
      }
    } catch (e) {
      print('❌ Error reanudando grabación: $e');
    }
  }

  /// Cancela la grabación actual y elimina el archivo
  Future<void> cancelRecording() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
        _durationTimer?.cancel();
        _durationTimer = null;
      }

      // Eliminar archivo si existe
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          print('🗑️ Grabación cancelada y archivo eliminado');
        }
      }

      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
    } catch (e) {
      print('❌ Error cancelando grabación: $e');
    }
  }

  /// Obtiene la amplitud actual del audio (para visualización)
  Future<double> getAmplitude() async {
    try {
      final amplitude = await _recorder.getAmplitude();
      // Normalizar a rango 0.0 - 1.0
      return (amplitude.current + 50) / 50; // -50 a 0 dB -> 0.0 a 1.0
    } catch (e) {
      return 0.0;
    }
  }

  /// Duración actual de la grabación
  Duration get currentDuration => _recordingDuration;

  /// Duración formateada (MM:SS)
  String get formattedDuration {
    final minutes = _recordingDuration.inMinutes;
    final seconds = _recordingDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Libera recursos
  void dispose() {
    _durationTimer?.cancel();
    _durationController.close();
    _recorder.dispose();
    print('🧹 AudioRecorderService disposed');
  }
}
