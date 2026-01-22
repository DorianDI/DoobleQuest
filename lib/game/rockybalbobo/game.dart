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
  String _debugDistance = "Initialisation...";

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
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller?.initialize();

    // Lancement du flux d'images
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
            if (mounted) setState(() => _debugDistance = "Cherche humain...");
          }
        }
      } catch (e) {
        debugPrint("Erreur IA : $e");
      }
      _isProcessing = false;
    });

    if (mounted) setState(() {});
  }

  void _detectPunch(Pose pose) {
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    double maxDistance = 0;

    // Calcul de la distance euclidienne
    if (rShoulder != null && rWrist != null) {
      maxDistance = sqrt(pow(rWrist.x - rShoulder.x, 2) + pow(rWrist.y - rShoulder.y, 2));
    }

    if (lShoulder != null && lWrist != null) {
      double distL = sqrt(pow(lWrist.x - lShoulder.x, 2) + pow(lWrist.y - lShoulder.y, 2));
      if (distL > maxDistance) maxDistance = distL;
    }

    if (mounted) {
      setState(() {
        _debugDistance = "Distance : ${maxDistance.toStringAsFixed(0)} px";
      });
    }

    // Seuil de détection (Threshold)
    const double punchThreshold = 150.0;

    if (!_isExtended && maxDistance > punchThreshold) {
      setState(() {
        _score++;
        _isExtended = true;
      });
      _playPunchSound();
      HapticFeedback.heavyImpact(); // Vibration Android
    } else if (maxDistance < punchThreshold * 0.6) {
      if (mounted) setState(() => _isExtended = false);
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        // IMPORTANT : Rotation 270 pour la majorité des Android en portrait
        rotation: InputImageRotation.rotation270deg,
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

    // Calcul pour éviter l'étirement (visage allongé)
    var scale = 1 / (_controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio);
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Caméra avec correction du ratio (Transform + AspectRatio)
          ClipRect(
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
          ),

          // 2. Texte de Debug
          Positioned(
            top: 50, left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(_debugDistance, style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // 3. Score
          Center(
            child: Text('$_score',
              style: const TextStyle(
                  fontFamily: 'Bangers', fontSize: 150, color: Colors.white,
                  shadows: [Shadow(blurRadius: 20, color: Colors.black)]
              ),
            ),
          ),

          // 4. Feedback visuel BAM
          if (_isExtended)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 200),
                child: Text("BAM !", style: TextStyle(fontFamily: 'Bangers', fontSize: 60, color: Colors.redAccent)),
              ),
            ),

          // 5. Quitter
          Positioned(
            top: 40, right: 20,
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