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
  // --- VARIABLES DE JEU ---
  int _gemCount = 0;
  bool _isDescending = false;
  String _debugValue = "Prêt ?";
  StreamSubscription? _accelSub;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- RÉGLAGES SENSIBILITÉ ASSOUPLIS ---
  // On passe de 2.2 à 1.2 pour faciliter la détection
  static const double _downThreshold = -1.2;
  static const double _upThreshold = 1.2;

  @override
  void initState() {
    super.initState();
    _startMovementDetection();
  }

  Future<void> _playCoinSound() async {
    try {
      await _audioPlayer.play(AssetSource('sfx/coin.mp3'));
    } catch (e) {
      debugPrint("Erreur son : $e");
    }
  }

  void _startMovementDetection() {
    _accelSub = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!mounted) return;

      setState(() {
        // UTILISER L'AXE Z pour les mouvements verticaux
        _debugValue = "Axe Z : ${event.z.toStringAsFixed(2)}";

        // ÉTAPE 1 : Détecter la descente (le Z augmente quand on descend)
        if (!_isDescending && event.z > 0.3) {  // Seuil positif augmenté
          _isDescending = true;
          HapticFeedback.selectionClick();
        }

        // ÉTAPE 2 : Détecter la remontée (le Z diminue quand on remonte)
        if (_isDescending && event.z < -0.5) {  // Seuil négatif
          _gemCount++;
          _isDescending = false;
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
            Text(_debugValue, style: const TextStyle(color: Colors.white24, fontSize: 14)),
            const SizedBox(height: 30),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.all(_isDescending ? 35 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  if (_isDescending)
                    BoxShadow(
                      color: const Color(0xFF63CCE9).withValues(alpha:0.5),
                      blurRadius: 40,
                      spreadRadius: 5,
                    )
                ],
              ),
              child: Image.asset(
                'assets/img/game/gemme.png',
                width: 160,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'GEMMES RÉCOLTÉES',
              style: TextStyle(fontFamily: 'Bangers', fontSize: 24, color: Color(0xFF7C8ED0)),
            ),
            Text(
              '$_gemCount',
              style: const TextStyle(fontFamily: 'Bangers', fontSize: 90, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: _isDescending ? const Color(0xFF63CCE9) : Colors.white10),
                color: _isDescending ? const Color(0xFF63CCE9).withValues(alpha:0.1) : Colors.transparent,
              ),
              child: Text(
                _isDescending ? "REMONTE ! ⬆️" : "DESCENDS ! ⬇️",
                style: TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 28,
                  color: _isDescending ? const Color(0xFF63CCE9) : const Color(0xFFF49A24),
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'QUITTER LA MINE',
                style: TextStyle(fontFamily: 'Bangers', color: Colors.white38, fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}