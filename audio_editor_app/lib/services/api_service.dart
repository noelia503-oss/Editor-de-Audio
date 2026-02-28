import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_record.dart';

/// Servicio para comunicación con el backend FastAPI
class ApiService {
  late final Dio _dio;

  // URL del backend (cámbialo si usas un servidor remoto)
  // Para iOS Simulator usa: 'http://localhost:8000'
  // Para Android Emulator usa: 'http://10.0.2.2:8000'
  // Para dispositivo físico usa la IP de tu computadora: 'http://192.168.x.x:8000'
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:8000'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5), // Procesamiento puede tomar tiempo
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Interceptor para logging (útil para debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 API: $obj'),
    ));
  }

  /// Verifica si el servidor está disponible
  Future<bool> checkServerHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error verificando servidor: $e');
      return false;
    }
  }

  /// Procesa un archivo de audio
  ///
  /// [audioFile]: Archivo de audio a procesar
  /// [noiseReduction]: Intensidad de reducción de ruido (0.0-1.0)
  /// [applyReverb]: Si aplicar reverb o no
  ///
  /// Retorna un [AudioRecord] con la información del procesamiento
  Future<AudioRecord> processAudio({
    required File audioFile,
    double noiseReduction = 0.7,
    bool applyReverb = true,
    Function(double)? onProgress,
  }) async {
    try {
      print('📤 Enviando audio al servidor...');

      // Preparar el formulario multipart
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'noise_reduction': noiseReduction,
        'apply_reverb': applyReverb,
      });

      // Enviar petición
      final response = await _dio.post(
        '/process-audio',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final record = AudioRecord.fromJson(data);

        print('✅ Audio procesado exitosamente');
        return record;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error de red: ${e.message}');
      if (e.response != null) {
        throw Exception('Error del servidor: ${e.response?.data['detail'] ?? e.message}');
      } else {
        throw Exception('No se pudo conectar con el servidor. Verifica que esté corriendo en $baseUrl');
      }
    } catch (e) {
      print('❌ Error procesando audio: $e');
      rethrow;
    }
  }

  /// Descarga el audio procesado
  ///
  /// [record]: Registro del audio procesado
  /// [onProgress]: Callback opcional para progreso de descarga
  ///
  /// Retorna la ruta del archivo descargado
  Future<String> downloadProcessedAudio({
    required AudioRecord record,
    Function(double)? onProgress,
  }) async {
    try {
      print('📥 Descargando audio procesado...');

      // Obtener directorio de documentos
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/processed_audios');

      // Crear directorio si no existe
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Ruta donde guardar el archivo
      final filePath = '${downloadsDir.path}/${record.id}_processed.wav';

      // Descargar
      await _dio.download(
        record.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total > 0) {
            onProgress(received / total);
          }
        },
      );

      print('✅ Audio descargado: $filePath');
      return filePath;
    } on DioException catch (e) {
      print('❌ Error descargando: ${e.message}');
      throw Exception('Error descargando audio: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Obtiene el historial de procesamientos
  Future<List<AudioRecord>> getHistory() async {
    try {
      print('📜 Obteniendo historial...');

      final response = await _dio.get('/history');

      if (response.statusCode == 200) {
        final history = response.data['history'] as List;
        final records = history
            .map((json) => AudioRecord.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ Historial obtenido: ${records.length} registros');
        return records;
      } else {
        throw Exception('Error obteniendo historial: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error obteniendo historial: ${e.message}');
      return []; // Retornar lista vacía en caso de error
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  /// Limpia archivos temporales del servidor (útil para desarrollo)
  Future<bool> cleanServerFiles() async {
    try {
      final response = await _dio.delete('/clean');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error limpiando archivos: $e');
      return false;
    }
  }

  /// Obtiene información del API
  Future<Map<String, dynamic>?> getApiInfo() async {
    try {
      final response = await _dio.get('/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Error obteniendo info del API: $e');
      return null;
    }
  }
}
