import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class RockyCameraView extends StatefulWidget {
  const RockyCameraView({super.key});
  @override
  State<RockyCameraView> createState() => _RockyCameraViewState();
}

class _RockyCameraViewState extends State<RockyCameraView> {
  CameraController? _controller;
  bool _isProcessing = false;
  int _score = 0;
  bool _isExtended = false;
  String _debugDistance = "Initialisation... ";

  final AudioPlayer _audioPlayer = AudioPlayer();
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream)
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      // Sécurité pour simulateur : vérifie si une caméra existe
      if (cameras.isEmpty) {
        if (mounted) setState(() => _debugDistance = "Pas de caméra (simulateur)");
        return;
      }

      // Tente de trouver la caméra frontale, sinon prend la première
      final camera = cameras.any((c) => c.lensDirection == CameraLensDirection.front)
          ? cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front)
          : cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );

      await _controller?.initialize();

      if (mounted) setState(() => _debugDistance = "IA active");

      _controller?.startImageStream((CameraImage image) async {
        if (_isProcessing) return;
        _isProcessing = true;

        try {
          final inputImage = _inputImageFromCameraImage(image);
          if (inputImage != null) {
            final poses = await _poseDetector.processImage(inputImage);
            if (poses.isNotEmpty) {
              _detectPunch(poses.first);
            }
          }
        } catch (e) {
          debugPrint("Erreur stream : $e");
        }
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) setState(() => _debugDistance = "Erreur Camera : $e");
    }
    if (mounted) setState(() {});
  }

  void _detectPunch(Pose pose) {
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (rShoulder != null && rWrist != null) {
      // Calcul de la distance $d = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}$
      final double distance = sqrt(pow(rWrist.x - rShoulder.x, 2) + pow(rWrist.y - rShoulder.y, 2));

      // Seuil de déclenchement (ajustable)
      const double punchThreshold = 180.0;

      if (!_isExtended && distance > punchThreshold) {
        if (mounted) {
          setState(() {
            _score++;
            _isExtended = true;
            _debugDistance = "PUNCH !";
          });
        }
        _playPunchSound();
        HapticFeedback.lightImpact();
      } else if (_isExtended && distance < punchThreshold * 0.6) {
        if (mounted) setState(() => _isExtended = false);
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // Reconstruction propre des bytes pour ML Kit
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageRotation = InputImageRotation.rotation270deg;
    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.yuv420;

    final inputImageMetadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  Future<void> _playPunchSound() async {
    try {
      await _audioPlayer.stop(); // Reset pour pouvoir rejouer vite
      await _audioPlayer.play(AssetSource('sfx/coup_de_poing.mp3'));
    } catch (e) {
      debugPrint("Erreur son : $e");
    }
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetector.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement ou erreur
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _debugDistance,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    // Calcul du scale pour éviter l'étirement
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Preview de la caméra
          Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(_controller!)),
          ),

          // Overlay UI
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                _debugDistance,
                style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
              ),
            ),
          ),

          // Score central
          Center(
            child: Text(
              '$_score',
              style: const TextStyle(
                fontSize: 150,
                color: Colors.white,
                fontWeight: FontWeight.w900, // Correction apportée ici
                shadows: [Shadow(blurRadius: 15, color: Colors.black54)],
              ),
            ),
          ),

          // Bouton quitter
          Positioned(
            bottom: 40,
            right: 25,
            child: FloatingActionButton(
              backgroundColor: Colors.white24,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}