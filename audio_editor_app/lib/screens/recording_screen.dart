import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_recorder_service.dart';
import '../services/api_service.dart';
import '../widgets/waveform_painter.dart';
import 'playback_screen.dart';

/// Pantalla principal de grabación de audio
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final ApiService _apiService = ApiService();

  bool _isRecording = false;
  bool _isProcessing = false;
  double _currentAmplitude = 0.0;
  Duration _recordingDuration = Duration.zero;
  Timer? _amplitudeTimer;

  // Configuración de procesamiento
  double _noiseReduction = 0.7;
  bool _applyReverb = true;

  File? _recordedFile;

  @override
  void initState() {
    super.initState();
    _checkServerConnection();

    // Escuchar cambios en la duración
    _recorderService.durationStream.listen((duration) {
      setState(() {
        _recordingDuration = duration;
      });
    });
  }

  /// Verifica la conexión con el servidor
  Future<void> _checkServerConnection() async {
    final isConnected = await _apiService.checkServerHealth();
    if (!isConnected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No se puede conectar con el servidor'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Inicia/detiene la grabación
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Detener grabación
      final file = await _recorderService.stopRecording();
      _amplitudeTimer?.cancel();

      setState(() {
        _isRecording = false;
        _recordedFile = file;
        _currentAmplitude = 0.0;
      });

      if (file != null) {
        // Mostrar opciones: procesar o descartar
        _showProcessingDialog();
      }
    } else {
      // Iniciar grabación
      final path = await _recorderService.startRecording();

      if (path != null) {
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });

        // Timer para actualizar amplitud (para visualización)
        _amplitudeTimer = Timer.periodic(
          const Duration(milliseconds: 100),
          (_) async {
            final amplitude = await _recorderService.getAmplitude();
            setState(() {
              _currentAmplitude = amplitude;
            });
          },
        );
      }
    }
  }

  /// Muestra diálogo para procesar o descartar la grabación
  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('🎵 Grabación completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duración: ${_formatDuration(_recordingDuration)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            const Text(
              'Configuración de procesamiento:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Reducción de ruido: ${(_noiseReduction * 100).toInt()}%'),
            Text('Reverb: ${_applyReverb ? "Activado" : "Desactivado"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _recordedFile = null;
              Navigator.pop(context);
            },
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSettingsDialog();
            },
            child: const Text('Ajustes'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processAudio();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Procesar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de ajustes de procesamiento
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('⚙️ Configuración'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Reducción de ruido'),
              Slider(
                value: _noiseReduction,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: Colors.orange,
                label: '${(_noiseReduction * 100).toInt()}%',
                onChanged: (value) {
                  setDialogState(() => _noiseReduction = value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Efecto Reverb'),
                subtitle: const Text('Añade espacio y profundidad'),
                value: _applyReverb,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setDialogState(() => _applyReverb = value);
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processAudio();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Procesar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Procesa el audio grabado
  Future<void> _processAudio() async {
    if (_recordedFile == null) return;

    setState(() => _isProcessing = true);

    try {
      // Mostrar diálogo de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 20),
              Text('🎛️ Procesando audio...'),
              SizedBox(height: 10),
              Text(
                'Esto puede tomar unos segundos',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      );

      // Procesar audio
      final record = await _apiService.processAudio(
        audioFile: _recordedFile!,
        noiseReduction: _noiseReduction,
        applyReverb: _applyReverb,
      );

      // Descargar audio procesado
      final processedPath = await _apiService.downloadProcessedAudio(
        record: record,
      );

      // Actualizar el record con la ruta local
      record.localPath = processedPath;

      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de progreso

        // Navegar a pantalla de reproducción
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaybackScreen(record: record),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de progreso

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
        _recordedFile = null;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _recorderService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('🎸 Editor de Audio'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Visualización de forma de onda
            Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: WaveformVisualizer(
                amplitude: _currentAmplitude,
                color: Colors.orange,
                isRecording: _isRecording,
              ),
            ),

            const SizedBox(height: 40),

            // Duración de la grabación
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 20),

            // Estado
            Text(
              _isRecording
                  ? '🎙️ Grabando...'
                  : _isProcessing
                      ? '⚙️ Procesando...'
                      : 'Presiona el botón para grabar',
              style: TextStyle(
                fontSize: 16,
                color: _isRecording ? Colors.orange : Colors.white70,
              ),
            ),

            const Spacer(),

            // Botón de grabar
            GestureDetector(
              onTap: _isProcessing ? null : _toggleRecording,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.orange,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.red : Colors.orange)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Configuración rápida
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reducción de ruido'),
                      Text('${(_noiseReduction * 100).toInt()}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reverb'),
                      Text(_applyReverb ? 'Activado' : 'Desactivado'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
