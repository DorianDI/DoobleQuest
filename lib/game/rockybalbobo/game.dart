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
  // Message de départ
  String _debugDistance = "Démarrage caméra...";

  final AudioPlayer _audioPlayer = AudioPlayer();
  // On utilise le mode 'stream' pour la rapidité
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream)
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    // Pré-chargement du son
    _audioPlayer.setSource(AssetSource('sfx/punch.mp3'));
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // Recherche de la caméra frontale
      final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Medium suffit pour l'IA et est plus rapide
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Format standard Android
      );

      await _controller?.initialize();

      if (mounted) setState(() => _debugDistance = "Caméra OK. Lancement IA...");

      // Démarrage du flux d'images vers l'IA
      _controller?.startImageStream((CameraImage image) async {
        if (_isProcessing) return;
        _isProcessing = true;

        try {
          // Conversion de l'image pour ML Kit
          final inputImage = _inputImageFromCameraImage(image);

          if (inputImage != null) {
            final poses = await _poseDetector.processImage(inputImage);

            // --- DIAGNOSTIC IA ---
            if (poses.isNotEmpty) {
              // Si on est ici, c'est GAGNÉ : l'IA te voit !
              _detectPunch(poses.first);
            } else {
              // Si ce message s'affiche alors que tu es devant, c'est un problème de rotation.
              if (mounted) setState(() => _debugDistance = "Je ne vois personne (Mauvaise rotation ?)");
            }
          }
        } catch (e) {
          debugPrint("Erreur IA : $e");
        }
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) setState(() => _debugDistance = "Erreur Caméra : Vérifier permissions");
    }
    if (mounted) setState(() {});
  }

  // Fonction qui analyse le squelette détecté
  void _detectPunch(Pose pose) {
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    // On vérifie si l'épaule et le poignet droits sont visibles avec une bonne confiance
    if (rShoulder != null && rWrist != null && rShoulder.likelihood > 0.5 && rWrist.likelihood > 0.5) {

      // Calcul de la distance euclidienne (Pythagore)
      final double distance = sqrt(pow(rWrist.x - rShoulder.x, 2) + pow(rWrist.y - rShoulder.y, 2));

      // Affichage en direct de la distance pour le debug
      if (mounted) setState(() => _debugDistance = "Distance bras : ${distance.toStringAsFixed(0)} px");

      // Seuil de détection du coup de poing (ajuster si besoin)
      const double punchThreshold = 160.0;

      // Logique du coup de poing (Extension puis rétraction)
      if (!_isExtended && distance > punchThreshold) {
        setState(() {
          _score++;
          _isExtended = true;
        });
        _playPunchSound();
        HapticFeedback.lightImpact(); // Petite vibration
      } else if (distance < punchThreshold * 0.7) {
        // On considère le bras rétracté s'il redescend sous 70% du seuil
        if (mounted) setState(() => _isExtended = false);
      }
    }
  }

  // --- C'EST ICI QUE LA CORRECTION PRINCIPALE SE TROUVE ---
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        // FIX ROTATION ANDROID PORTRAIT :
        // On force la rotation à 270 degrés. C'est le standard pour la caméra avant.
        rotation: InputImageRotation.rotation270deg,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _playPunchSound() async {
    try { await _audioPlayer.resume(); } catch (e) {
      try { await _audioPlayer.play(AssetSource('sfx/punch.mp3')); } catch(e2) {}
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
    // Si la caméra n'est pas prête, on affiche le message de debug au centre noir
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(backgroundColor: Colors.black, body: Center(child: Text(_debugDistance, style: const TextStyle(color: Colors.white))));
    }

    // --- FIX AFFICHAGE ANDROID (Pour garder ton image non déformée) ---
    final size = MediaQuery.of(context).size;
    // On calcule le ratio nécessaire pour remplir l'écran sans déformer
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    // Si l'image est moins large que l'écran, on inverse l'échelle pour zoomer
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. La Caméra (Mise à l'échelle pour remplir l'écran)
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),

          // 2. Overlay d'interface sombre pour faire ressortir les textes
          Container(color: Colors.black.withOpacity(0.2)),

          // 3. Texte de Debug en haut à gauche (ESSENTIEL POUR TESTER)
          Positioned(
            top: 50, left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Text(_debugDistance, style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // 4. Le Score au centre
          Center(
            child: Text('$_score', style: const TextStyle(fontFamily: 'Bangers', fontSize: 150, color: Colors.white, shadows: [Shadow(blurRadius: 20, color: Colors.black)])),
          ),

          // 5. Bouton pour quitter
          Positioned(
            top: 40, right: 20,
            child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 40), onPressed: () => Navigator.pop(context)),
          )
        ],
      ),
    );
  }
}