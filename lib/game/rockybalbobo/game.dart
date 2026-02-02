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

  // Variables pour la détection de mouvement
  double? _previousRightWristX;
  double? _previousRightWristY;

  bool _punchCooldown = false;
  bool _isLoading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream)
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _audioPlayer.setSource(AssetSource('sfx/punch.mp3'));
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller?.initialize();

      if (mounted) setState(() => _isLoading = false);

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
          // Erreur silencieuse
        }
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
    if (mounted) setState(() {});
  }

  void _detectPunch(Pose pose) {
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    bool canDetect = rShoulder != null && rElbow != null && rWrist != null &&
        rShoulder.likelihood > 0.5 && rElbow.likelihood > 0.5 && rWrist.likelihood > 0.5;

    if (!canDetect) return;

    // CALCUL VÉLOCITÉ
    double velocity = 0;
    if (_previousRightWristX != null && _previousRightWristY != null) {
      double dx = (rWrist!.x - _previousRightWristX!).abs();
      double dy = (rWrist.y - _previousRightWristY!).abs();
      velocity = sqrt(dx * dx + dy * dy);
    }

    // CALCUL EXTENSION
    double extension = sqrt(
        pow(rWrist!.x - rShoulder!.x, 2) +
            pow(rWrist.y - rShoulder.y, 2)
    );

    // CALCUL ANGLE
    double angle = _calculateAngle(
        rShoulder.x, rShoulder.y,
        rElbow!.x, rElbow.y,
        rWrist.x, rWrist.y
    );

    // DÉCISION
    bool isPunch = velocity > 50 && extension > 130 && angle > 145 && !_punchCooldown;

    if (isPunch) {
      setState(() {
        _score++;
        _punchCooldown = true;
      });

      _playPunchSound();
      HapticFeedback.heavyImpact();

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _punchCooldown = false);
      });
    }

    _previousRightWristX = rWrist.x;
    _previousRightWristY = rWrist.y;
  }

  double _calculateAngle(double x1, double y1, double x2, double y2, double x3, double y3) {
    double v1x = x1 - x2;
    double v1y = y1 - y2;
    double v2x = x3 - x2;
    double v2y = y3 - y2;

    double dotProduct = v1x * v2x + v1y * v2y;
    double mag1 = sqrt(v1x * v1x + v1y * v1y);
    double mag2 = sqrt(v2x * v2x + v2y * v2y);

    if (mag1 == 0 || mag2 == 0) return 0;

    double angleRad = acos((dotProduct / (mag1 * mag2)).clamp(-1.0, 1.0));
    return angleRad * 180 / pi;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _playPunchSound() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      try {
        await _audioPlayer.play(AssetSource('sfx/punch.mp3'));
      } catch(e2) {}
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
    if (_controller == null || !_controller!.value.isInitialized || _isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Color(0xFFD11F41)),
              SizedBox(height: 20),
              Text(
                'Chargement de la caméra...',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Caméra
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),

          // Overlay sombre léger
          Container(color: Colors.black.withOpacity(0.3)),

          // Score au centre
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 180,
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 30, color: Colors.black),
                      Shadow(blurRadius: 30, color: Color(0xFFD11F41)),
                    ],
                  ),
                ),
                const Text(
                  'COUPS',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 32,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          // Instructions en bas
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD11F41), width: 2),
              ),
              child: Column(
                children: const [
                  Text(
                    '🥊 CONSEILS',
                    style: TextStyle(
                      color: Color(0xFFD11F41),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mettez-vous DE PROFIL • Frappez RAPIDEMENT\nRevenez en garde entre chaque coup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bouton quitter
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}