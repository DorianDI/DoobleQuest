import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';

class TireCowboyGamePage extends StatefulWidget {
  const TireCowboyGamePage({super.key});

  @override
  State<TireCowboyGamePage> createState() => _TireCowboyGamePageState();
}

class _TireCowboyGamePageState extends State<TireCowboyGamePage> {
  static const int waitDuration = 12;
  static const double sensitivity = 28.0;

  bool _isWaiting = true;
  bool _isGameOver = false;
  String _message = "NE BOUGE PAS...";

  DateTime? _signalTime;
  Duration? _reactionTime;
  StreamSubscription? _accelSub;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _startDuel();
  }

  void _startDuel() {
    _gameTimer = Timer(const Duration(seconds: waitDuration), () {
      if (!_isGameOver) {
        setState(() {
          _isWaiting = false;
          _message = "TIRE !";
          _signalTime = DateTime.now();
        });
        Future.wait([
          HapticFeedback.heavyImpact(),
          Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.heavyImpact()),
          Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact()),
        ]);
      }
    });

    _accelSub = accelerometerEventStream().listen((event) {
      if (_isGameOver) return;
      final force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (force > sensitivity) {
        if (_isWaiting) {
          _endGame("TROP TÔT !", "Faux départ, cowboy...", Colors.red);
        } else {
          final now = DateTime.now();
          _reactionTime = now.difference(_signalTime!);
          _endGame("PAN !", "${_reactionTime!.inMilliseconds} ms", const Color(0xFFF49A24));
        }
      }
    });
  }

  void _endGame(String title, String sub, Color color) {
    _accelSub?.cancel();
    _gameTimer?.cancel();
    setState(() {
      _isGameOver = true;
      _message = title;
      _reactionTime != null ? _message = "$title\n$sub" : _message = title;
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF49A24)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF1D132E),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isWaiting ? Colors.transparent : const Color(0xFFF49A24).withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: 60,
                color: _isGameOver && _reactionTime == null ? Colors.red : const Color(0xFFF49A24),
              ),
            ),
            if (_isGameOver) ...[
              const SizedBox(height: 40),
              _actionButton("REJOUER", () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TireCowboyGamePage()))),
              const SizedBox(height: 10),
              _actionButton("MENU", () => Navigator.pop(context)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF49A24))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Bangers')),
    );
  }
}