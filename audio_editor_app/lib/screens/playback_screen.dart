import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../models/audio_record.dart';

/// Pantalla para reproducir y compartir el audio procesado
class PlaybackScreen extends StatefulWidget {
  final AudioRecord record;

  const PlaybackScreen({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  /// Configura el reproductor de audio
  void _setupAudioPlayer() {
    // Escuchar cambios en el estado de reproducción
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // Escuchar cambios en la posición
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Escuchar duración total
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // Cuando termina la reproducción
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _currentPosition = Duration.zero;
        _isPlaying = false;
      });
    });
  }

  /// Reproduce o pausa el audio
  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (widget.record.localPath != null) {
        await _audioPlayer.play(DeviceFileSource(widget.record.localPath!));
      }
    }
  }

  /// Detiene la reproducción
  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _currentPosition = Duration.zero;
      _isPlaying = false;
    });
  }

  /// Comparte el audio procesado
  Future<void> _shareAudio() async {
    if (widget.record.localPath != null) {
      try {
        await Share.shareXFiles(
          [XFile(widget.record.localPath!)],
          text: 'Audio procesado con Editor de Audio 🎸',
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error compartiendo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Formatea la duración
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('✅ Audio Procesado'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAudio,
            tooltip: 'Compartir',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Icono grande de éxito
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 40),

              // Información del archivo
              _buildInfoCard(),

              const SizedBox(height: 40),

              // Controles de reproducción
              _buildPlaybackControls(progress),

              const Spacer(),

              // Botones de acción
              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Card con información del audio
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.record.originalFilename,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.access_time, 'Duración', widget.record.formattedDuration),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, 'Fecha', widget.record.formattedDate),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.file_present, 'Tamaño', widget.record.fileSizes.formattedProcessedSize),
          const Divider(height: 24, color: Colors.white24),
          Text(
            widget.record.settings.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Fila de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.orange),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// Controles de reproducción
  Widget _buildPlaybackControls(double progress) {
    return Column(
      children: [
        // Barra de progreso
        SliderTheme(
          data: SliderThemeData(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            trackHeight: 4,
            activeTrackColor: Colors.orange,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.orange,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) async {
              final position = Duration(
                milliseconds: (value * _totalDuration.inMilliseconds).toInt(),
              );
              await _audioPlayer.seek(position);
            },
          ),
        ),

        // Tiempo actual / total
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Botones de control
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón de stop
            IconButton(
              onPressed: _stopPlayback,
              icon: const Icon(Icons.stop),
              iconSize: 36,
              color: Colors.white70,
            ),
            const SizedBox(width: 40),

            // Botón de play/pause
            GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 40),

            // Espacio para simetría
            const SizedBox(width: 36),
          ],
        ),
      ],
    );
  }

  /// Botones de acción
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón de compartir
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _shareAudio,
            icon: const Icon(Icons.share),
            label: const Text('Compartir Audio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botón de volver
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.mic),
            label: const Text('Grabar Nuevo Audio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
