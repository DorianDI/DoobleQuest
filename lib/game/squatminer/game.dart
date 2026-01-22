import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SquatMinerGamePage extends StatefulWidget {
  const SquatMinerGamePage({super.key});

  @override
  State<SquatMinerGamePage> createState() => _SquatMinerGamePageState();
}

class _SquatMinerGamePageState extends State<SquatMinerGamePage> {
  int _gemCount = 0;
  bool _isDown = false;
  StreamSubscription? _accelSub;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- RÉGLAGES (Sensibilité) ---
  static const double _downThreshold = -3.0; // Seuil de descente
  static const double _upThreshold = 2.5;    // Seuil de remontée

  @override
  void initState() {
    super.initState();
    _startMovementDetection();
  }

  // --- LOGIQUE SONORE ---
  Future<void> _playCoinSound() async {
    try {
      await _audioPlayer.play(AssetSource('sfx/coin.mp3'));
    } catch (e) {
      debugPrint("Erreur son : $e");
    }
  }

  // --- LOGIQUE DE MOUVEMENT ---
  void _startMovementDetection() {
    _accelSub = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!mounted) return;

      setState(() {
        // 1. Détection de la descente (Axe Y)
        if (!_isDown && event.y < _downThreshold) {
          _isDown = true;
          HapticFeedback.selectionClick();
        }

        // 2. Validation à la remontée
        if (_isDown && event.y > _upThreshold) {
          _gemCount++;
          _isDown = false;
          _playCoinSound();
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF49A24)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.all(_isDown ? 15 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  if (_isDown)
                    BoxShadow(
                      color: const Color(0xFF63CCE9).withOpacity(0.7),
                      blurRadius: 50,
                      spreadRadius: 10,
                    )
                ],
              ),
              child: Image.asset(
                'assets/img/game/gemme.png',
                width: 150,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 50),

            const Text(
              'GEMMES :',
              style: TextStyle(fontFamily: 'Bangers', fontSize: 30, color: Color(0xFF7C8ED0)),
            ),
            Text(
              '$_gemCount',
              style: const TextStyle(fontFamily: 'Bangers', fontSize: 80, color: Colors.white),
            ),

            const SizedBox(height: 50),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: _isDown ? const Color(0xFF63CCE9) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: _isDown ? Colors.transparent : const Color(0xFFF49A24).withOpacity(0.5),
                    width: 2
                ),
              ),
              child: Text(
                _isDown ? "REMONTE !" : "DESCENDS !",
                style: TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 28,
                  color: _isDown ? const Color(0xFF1D132E) : const Color(0xFFF49A24),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // --- BOUTON RETOUR ---
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ARRÊTER LA MINE',
                style: TextStyle(fontFamily: 'Bangers', color: Color(0xFF7C8ED0), fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}