import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'nail.dart';

class FlashMcClouGamePage extends StatefulWidget {
  const FlashMcClouGamePage({super.key});

  @override
  State<FlashMcClouGamePage> createState() => _FlashMcClouGamePageState();
}

class _FlashMcClouGamePageState extends State<FlashMcClouGamePage> {
  static const int gameDurationSec = 30;

  StreamSubscription? _sub;
  Timer? _timer;

  double _progress = 0.0;
  int _timeLeft = gameDurationSec;

  bool _finished = false;
  bool _won = false;

  DateTime _lastHit = DateTime.fromMillisecondsSinceEpoch(0);

  final double _hitThreshold = 12.0;
  final Duration _hitCooldown = const Duration(milliseconds: 140);
  final double _progressPerHit = 0.06;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _stopAll();
    super.dispose();
  }

  void _startGame() {
    _stopAll();

    setState(() {
      _progress = 0;
      _timeLeft = gameDurationSec;
      _finished = false;
      _won = false;
    });

    // Timer 30s
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (_finished) {
        t.cancel();
        return;
      }

      if (_timeLeft <= 1) {
        setState(() {
          _timeLeft = 0;
          _finished = true;
          _won = _progress >= 1.0;
        });
        _stopSensorsOnly();
      } else {
        setState(() => _timeLeft -= 1);
      }
    });

    // Capteurs
    _sub = accelerometerEventStream().listen((e) {
      if (_finished) return;
      final double hitSignal = -e.y;

      final now = DateTime.now();
      final canHit = now.difference(_lastHit) >= _hitCooldown;

      if (canHit && hitSignal > _hitThreshold) {
        _lastHit = now;

        final newProgress = (_progress + _progressPerHit).clamp(0.0, 1.0);
        if (newProgress != _progress) {
          setState(() => _progress = newProgress);
        }

        if (_progress >= 1.0) {
          setState(() {
            _finished = true;
            _won = true;
          });
          _stopSensorsOnly();
        }
      }
    });
  }

  void _stopSensorsOnly() {
    _sub?.cancel();
    _sub = null;
  }

  void _stopAll() {
    _timer?.cancel();
    _timer = null;
    _stopSensorsOnly();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF63CCE9)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: CustomPaint(
                size: const Size(120, 300),
                painter: NailPainter(progress: _progress),
              ),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: !_finished
                  ? Column(
                      key: const ValueKey("playing"),
                      children: [
                        Text(
                          "Temps: $_timeLeft s",
                          style: const TextStyle(
                            color: Color(0xFF63CCE9),
                            fontSize: 22,
                            fontFamily: 'Bangers',
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "CLOUE !",
                          style: TextStyle(
                            color: Color(0xFF7C8ED0),
                            fontSize: 18,
                            fontFamily: 'Bangers',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    )
                  : Text(
                _won ? "GG ! Clou enfoncé" : "Perdu… retente !",
                key: const ValueKey("result"),
                style: const TextStyle(
                  color: Color(0xFF63CCE9),
                  fontSize: 22,
                  fontFamily: 'Bangers',
                ),
              ),
            ),
            const Spacer(),
            if (_finished)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  children: [
                    _bigButton(
                      label: "RECOMMENCER",
                      onTap: _startGame,
                    ),
                    const SizedBox(height: 12),
                    _bigButton(
                      label: "QUITTER",
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _bigButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF63CCE9).withValues(alpha: 0.10),
          foregroundColor: const Color(0xFF63CCE9),
          elevation: 0,
          side: const BorderSide(color: Color(0xFF63CCE9), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontFamily: 'Bangers', fontSize: 22, letterSpacing: 1),
        ),
      ),
    );
  }
}
