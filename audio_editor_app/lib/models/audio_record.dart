/// Modelo de datos para un registro de audio procesado
class AudioRecord {
  final String id;
  final String originalFilename;
  final DateTime timestamp;
  final double duration;
  final int sampleRate;
  final AudioSettings settings;
  final FileSizes fileSizes;
  final String downloadUrl;
  String? localPath; // Ruta local del archivo descargado

  AudioRecord({
    required this.id,
    required this.originalFilename,
    required this.timestamp,
    required this.duration,
    required this.sampleRate,
    required this.settings,
    required this.fileSizes,
    required this.downloadUrl,
    this.localPath,
  });

  /// Crear desde JSON (respuesta del backend)
  factory AudioRecord.fromJson(Map<String, dynamic> json) {
    return AudioRecord(
      id: json['id'] as String,
      originalFilename: json['original_filename'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: (json['duration'] as num).toDouble(),
      sampleRate: json['sample_rate'] as int,
      settings: AudioSettings.fromJson(json['settings'] as Map<String, dynamic>),
      fileSizes: FileSizes.fromJson(json['file_sizes'] as Map<String, dynamic>),
      downloadUrl: json['download_url'] as String,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_filename': originalFilename,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'sample_rate': sampleRate,
      'settings': settings.toJson(),
      'file_sizes': fileSizes.toJson(),
      'download_url': downloadUrl,
      'local_path': localPath,
    };
  }

  /// Duración formateada (ej: "2:30")
  String get formattedDuration {
    final minutes = (duration / 60).floor();
    final seconds = (duration % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Fecha formateada (ej: "27 Feb 2026, 14:30")
  String get formattedDate {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final day = timestamp.day;
    final month = months[timestamp.month - 1];
    final year = timestamp.year;
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }
}

/// Configuración de procesamiento de audio
class AudioSettings {
  final double noiseReduction;
  final bool applyReverb;

  AudioSettings({
    required this.noiseReduction,
    required this.applyReverb,
  });

  factory AudioSettings.fromJson(Map<String, dynamic> json) {
    return AudioSettings(
      noiseReduction: (json['noise_reduction'] as num).toDouble(),
      applyReverb: json['apply_reverb'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noise_reduction': noiseReduction,
      'apply_reverb': applyReverb,
    };
  }

  /// Descripción legible de la configuración
  String get description {
    final noisePercent = (noiseReduction * 100).toInt();
    final reverb = applyReverb ? 'Con reverb' : 'Sin reverb';
    return 'Reducción de ruido: $noisePercent% • $reverb';
  }
}

/// Tamaños de archivos
class FileSizes {
  final double originalMb;
  final double processedMb;

  FileSizes({
    required this.originalMb,
    required this.processedMb,
  });

  factory FileSizes.fromJson(Map<String, dynamic> json) {
    return FileSizes(
      originalMb: (json['original_mb'] as num).toDouble(),
      processedMb: (json['processed_mb'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_mb': originalMb,
      'processed_mb': processedMb,
    };
  }

  /// Tamaño formateado
  String get formattedProcessedSize {
    if (processedMb < 1) {
      return '${(processedMb * 1024).toStringAsFixed(0)} KB';
    }
    return '${processedMb.toStringAsFixed(1)} MB';
  }
}
