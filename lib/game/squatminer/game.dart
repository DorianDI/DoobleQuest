import 'dart:async';
import 'dart:math'; // FIX: Pour utiliser sqrt()
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
  String _debugValue = "Bouge le téléphone..."; // FIX: Déclaration de la variable
  StreamSubscription? _accelSub;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // On utilise une détection de force brute (Magnitude) pour que ça marche
  // peu importe comment tu tiens le téléphone.
  static const double _forceThreshold = 3.5;

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
      double totalForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      setState(() {
        _debugValue = "Force : ${totalForce.toStringAsFixed(2)}";

        // Détection du squat par accélération brusque
        if (!_isDown && totalForce > _forceThreshold) {
          _isDown = true;
          _gemCount++;
          _playCoinSound();
          HapticFeedback.heavyImpact();

          // On bloque la détection pendant 1.2s pour simuler le temps du squat
          Future.delayed(const Duration(milliseconds: 1200), () {
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
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Debug text pour voir si les capteurs bougent
            Text(_debugValue, style: const TextStyle(color: Colors.white54, fontSize: 14)),

            const SizedBox(height: 20),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(_isDown ? 20 : 0),
              child: Image.asset('assets/img/game/gemme.png', width: 150),
            ),

            const SizedBox(height: 40),

            const Text('GEMMES', style: TextStyle(fontFamily: 'Bangers', fontSize: 30, color: Color(0xFF7C8ED0))),
            Text('$_gemCount', style: const TextStyle(fontFamily: 'Bangers', fontSize: 80, color: Colors.white)),

            const SizedBox(height: 40),

            Text(
              _isDown ? "BIEN JOUÉ !" : "SQUAT !",
              style: TextStyle(fontFamily: 'Bangers', fontSize: 28, color: _isDown ? Colors.greenAccent : const Color(0xFFF49A24)),
            ),

            const SizedBox(height: 60),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('RETOUR', style: TextStyle(fontFamily: 'Bangers', color: Colors.white54, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}