import 'dart:async';
import 'dart:math'; // FIX: Nécessaire pour la fonction sqrt()
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
  String _debugValue = ""; // FIX: Déclaration de la variable manquante
  StreamSubscription? _accelSub;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Couleurs de la maquette
  final Color _neonGreen = const Color(0xFF39FF14);
  final Color _darkBg = const Color(0xFF1D132E);

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

      // Calcul de la force totale (Magnitude)
      // $totalForce = \sqrt{x^2 + y^2 + z^2}$
      double totalForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      setState(() {
        _debugValue = "Force: ${totalForce.toStringAsFixed(2)}";

        // Détection du mouvement de squat
        if (!_isDown && totalForce > 3.5) {
          _isDown = true;
          _gemCount++;
          _playCoinSound();
          HapticFeedback.heavyImpact();

          // Reset automatique après le mouvement
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) setState(() => _isDown = false);
          });
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
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Debug info
            Text(_debugValue, style: const TextStyle(color: Colors.white24, fontSize: 12)),

            // TITRE
            Text(
              'SQUAT MINER (스쿼트 마이너)',
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: 48,
                color: _neonGreen,
              ),
            ),

            const SizedBox(height: 40),

            // VISUEL CENTRAL (Mine + Gemme)
            Stack(
              alignment: Alignment.center,
              children: [
                // Cercle de fond (Mine)
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _neonGreen.withValues(alpha : 0.3), blurRadius: 40, spreadRadius: 5)
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/img/game/fond_mine.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gemme animée
                AnimatedScale(
                  scale: _isDown ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/img/game/gemme.png',
                    width: 200,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // SCORE
            const Text(
              'GEMMES (보석) :',
              style: TextStyle(fontFamily: 'Bangers', fontSize: 24, color: Colors.white70),
            ),
            Text(
              '$_gemCount',
              style: const TextStyle(fontFamily: 'Bangers', fontSize: 80, color: Colors.white),
            ),

            const Spacer(),

            // INDICATION DYNAMIQUE
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                color: _isDown ? _neonGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _neonGreen, width: 2),
              ),
              child: Text(
                _isDown ? "REMONTE ! (올라오세요!)" : "DESCENDS ! (내려가세요!)",
                style: TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 28,
                  color: _isDown ? _darkBg : _neonGreen,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOUTON QUITTER
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ARRÊTER LA MINE (광산 중지)',
                style: TextStyle(fontFamily: 'Bangers', color: Colors.white38, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} // FIX: Accolade fermante ajoutée ici