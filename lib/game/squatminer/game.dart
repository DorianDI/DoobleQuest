import 'dart:async';
import 'dart:math'; // Pour sqrt()
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
  bool _isDescending = false;
  String _debugValue = "En attente...";
  StreamSubscription? _accelSub;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const double _downThreshold = -2.2;
  static const double _upThreshold = 2.2;

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
        _debugValue = "Y: ${event.y.toStringAsFixed(2)}";

        if (!_isDescending && event.y < _downThreshold) {
          _isDescending = true;
          HapticFeedback.selectionClick();
        }

        if (_isDescending && event.y > _upThreshold) {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_debugValue, style: const TextStyle(color: Colors.white24)),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: Image.asset('assets/img/game/fond_mine.png', width: 260, height: 260, fit: BoxFit.cover),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_isDescending ? 40 : 0),
                  child: Image.asset('assets/img/game/gemme.png', width: 180),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text('$_gemCount', style: const TextStyle(fontFamily: 'Bangers', fontSize: 90, color: Colors.white)),
            Text(_isDescending ? "REMONTE !" : "DESCENDS !",
                style: const TextStyle(fontFamily: 'Bangers', fontSize: 32, color: Color(0xFFF49A24))),
          ],
        ),
      ),
    );
  }
}