import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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
  String _debugDistance = "Attente d'humain...";

  final AudioPlayer _audioPlayer = AudioPlayer();
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream)
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialisation de la caméra et branchement de l'IA
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Format standard Android
    );

    await _controller?.initialize();

    _controller?.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage != null) {
          final poses = await _poseDetector.processImage(inputImage);
          if (poses.isNotEmpty) {
            _detectPunch(poses.first);
          } else {
            setState(() => _debugDistance = "Personne détectée");
          }
        }
      } catch (e) {
        debugPrint("Erreur IA : $e");
      }
      _isProcessing = false;
    });

    if (mounted) setState(() {});
  }

  // Logique de détection de coup de poing (Mathématique et Physique)
  void _detectPunch(Pose pose) {
    // On récupère les points des deux bras pour plus de fiabilité
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    double maxDistance = 0;

    // Calcul de la distance pour le bras droit : $d = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}$
    if (rShoulder != null && rWrist != null) {
      maxDistance = sqrt(pow(rWrist.x - rShoulder.x, 2) + pow(rWrist.y - rShoulder.y, 2));
    }

    // On vérifie aussi le bras gauche (si l'utilisateur est tourné dans l'autre sens)
    if (lShoulder != null && lWrist != null) {
      double distL = sqrt(pow(lWrist.x - lShoulder.x, 2) + pow(lWrist.y - lShoulder.y, 2));
      if (distL > maxDistance) maxDistance = distL;
    }

    // MISE À JOUR DU DEBUG : Pour voir si le téléphone te "sent"
    setState(() {
      _debugDistance = "Distance : ${maxDistance.toStringAsFixed(0)} px";
    });

    // SEUIL DE VALIDATION (Ajusté à 170 pour plus de souplesse)
    const double punchThreshold = 170.0;

    if (!_isExtended && maxDistance > punchThreshold) {
      setState(() {
        _score++;
        _isExtended = true;
      });
      _playPunchSound();
      HapticFeedback.heavyImpact(); // Vibration Android
    } else if (maxDistance < punchThreshold * 0.6) {
      // On réinitialise quand le poing revient vers l'épaule
      if (mounted) setState(() => _isExtended = false);
    }
  }

  // Convertisseur technique indispensable pour Android
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg, // Rotation spécifique Android
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _playPunchSound() async {
    try {
      await _audioPlayer.play(AssetSource('sfx/punch.mp3'));
    } catch (e) {
      debugPrint("Erreur son : $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. La Caméra
          SizedBox.expand(child: CameraPreview(_controller!)),

          // 2. Overlay de Debug (Le chiffre rouge en haut)
          Positioned(
            top: 50, left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(_debugDistance, style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // 3. Le Score au centre
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_score',
                  style: const TextStyle(
                      fontFamily: 'Bangers', fontSize: 130, color: Colors.white,
                      shadows: [Shadow(blurRadius: 20, color: Colors.black)]
                  ),
                ),
                Text(_isExtended ? "BAM !" : "",
                    style: const TextStyle(fontFamily: 'Bangers', fontSize: 40, color: Colors.redAccent)),
              ],
            ),
          ),

          // 4. Bouton Quitter
          Positioned(
            bottom: 30, left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}