import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';


class CamilleKazeGamePage extends StatefulWidget {
  final int minSeconds;
  final int maxSeconds;
  const CamilleKazeGamePage({super.key, required this.minSeconds, required this.maxSeconds});

  @override
  State<CamilleKazeGamePage> createState() => _CamilleKazeGamePageState();
}

class _CamilleKazeGamePageState extends State<CamilleKazeGamePage> {
  final _rng = Random();
  Timer? _explodeTimer;
  Timer? _blinkTimer;
  Timer? _tickTimer;
  StreamSubscription? _accelSub;

  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _boomPlayer = AudioPlayer();
  bool _showExplosionFx = false;
  String _explodeReason = 'BOUM !';

  bool _running = false;
  bool _exploded = false;
  bool _blinkOn = true;

  late int _targetMs;         // temps total avant explosion
  late int _startMs;          // timestamp début
  int _elapsedMs = 0;

  // seuil “passage brusque”
  // (à ajuster après test : 18–28 généralement)
  static const double _jerkThreshold = 22.0;

  Future<void> _playTick() async {
    try {
      await _tickPlayer.stop();
      await _tickPlayer.play(AssetSource('sfx/tick.mp3'));
    } catch (e) {
      debugPrint('Tick error: $e');
    }
  }


  Future<void> _stopTickLoop() async {
    try {
      await _tickPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playBoom() async {
    try {
      await _boomPlayer.play(AssetSource('sfx/explosion.mp3')); // ✅ sans "assets/"
    } catch (e) {
      debugPrint('Boom audio error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _stopAll();
    _tickPlayer.dispose();
    _boomPlayer.dispose();
    super.dispose();
  }

  void _stopAll() {
    _explodeTimer?.cancel();
    _blinkTimer?.cancel();
    _tickTimer?.cancel();
    _accelSub?.cancel();
    _tickTimer?.cancel();
    _tickPlayer.stop();
  }

  void _startRound() {
    _stopAll();
    _scheduleTick();
    setState(() {
      _showExplosionFx = false;
      _explodeReason = '';
      _exploded = false;
      _running = true;
      _blinkOn = true;
      _elapsedMs = 0;
    });


    final seconds = widget.minSeconds + _rng.nextInt(widget.maxSeconds - widget.minSeconds + 1);
    _targetMs = seconds * 1000;
    _startMs = DateTime.now().millisecondsSinceEpoch;

    // Timer explosion
    _explodeTimer = Timer(Duration(milliseconds: _targetMs), _explode);

    // Clignotement (on accélère selon le temps restant)
    _scheduleBlink();

    // Tic-tac (pour l’instant: haptic léger, ensuite on met un son)
    _scheduleTick();

    // Détection mouvement brusque
    _accelSub = accelerometerEventStream().listen((e) {
      if (!_running || _exploded) return;
      final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (mag > _jerkThreshold) {
        _explode(reason: 'Passage trop brusque !');
      }
    });
  }

  void _explode({String reason = 'BOUM !'}) async {
    if (_exploded) return;

    _stopAll();

    setState(() {
      _explodeReason = reason;
      _running = false;
      _exploded = true;
      _showExplosionFx = true;
    });

    HapticFeedback.heavyImpact();
    await _playBoom(); // ton son boom (audioplayers)

    // laisse l’explosion visible
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    setState(() => _showExplosionFx = false);

    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

  }

  void _showExplodeDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D132E),
          title: const Text('💥 EXPLOSION', style: TextStyle(color: Color(0xFFF49A24))),
          content: Text(reason, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startRound(); // relance une manche
              },
              child: const Text('Rejouer', style: TextStyle(color: Color(0xFF7C8ED0))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // retour page précédente
              },
              child: const Text('Quitter', style: TextStyle(color: Color(0xFF7C8ED0))),
            ),
          ],
        );
      },
    );
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    if (!_running) return;

    final remaining = _remainingMs();
    // plus on approche de 0, plus ça clignote vite
    final interval = _mapRemainingToIntervalMs(remaining);
    _blinkTimer = Timer(Duration(milliseconds: interval), () {
      setState(() => _blinkOn = !_blinkOn);
      _scheduleBlink();
    });
  }

  void _scheduleTick() {
    _tickTimer?.cancel();
    if (!_running || _exploded) return;

    final remaining = _remainingMs();
    final interval = _mapRemainingToTickMs(remaining);

    _tickTimer = Timer(Duration(milliseconds: interval), () async {
      if (!_running || _exploded) return;
      await _playTick(); // 🔥 vrai tick
      _scheduleTick();   // 🔁 on reprogramme avec un intervalle plus court
    });
  }


  int _remainingMs() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _elapsedMs = now - _startMs;
    final rem = (_targetMs - _elapsedMs).clamp(0, _targetMs);
    return rem;
  }

  int _mapRemainingToIntervalMs(int remainingMs) {
    // clignote lent au début, très rapide à la fin
    if (remainingMs > 15000) return 500;
    if (remainingMs > 8000) return 300;
    if (remainingMs > 3000) return 180;
    return 90;
  }

  int _mapRemainingToTickMs(int remainingMs) {
    if (remainingMs > 15000) return 1800; // lent (presque 1 tick complet)
    if (remainingMs > 8000)  return 1200;
    if (remainingMs > 4000)  return 700;
    if (remainingMs > 2000)  return 450;
    return 250; // panique totale 😈
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFF49A24)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zone visuelle (bombe + explosion par-dessus)
            Stack(
              alignment: Alignment.center,
              children: [
                // Bombe toujours visible (jeu + perdu)
                AnimatedOpacity(
                  opacity: (!_exploded && _blinkOn) ? 1.0 : 0.75, // un peu grisé en perdu
                  duration: const Duration(milliseconds: 80),
                  child: Image.asset(
                    'assets/img/game/bombe.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),

                // Explosion par-dessus seulement pendant le FX
                if (_showExplosionFx)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.6, end: 1.2),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Image.asset(
                      'assets/img/game/explosion.png',
                      width: 260,
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Texte en mode jeu
            if (!_exploded)
              const Text(
                'Passez à un autre joueur !',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

            // UI en mode perdu
            if (_exploded) ...[
              const Text(
                'Vous avez perdu 💥',
                style: TextStyle(
                  color: Color(0xFFF49A24),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _explodeReason,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _startRound,
                    child: const Text(
                      'Rejouer',
                      style: TextStyle(color: Color(0xFF7C8ED0), fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Quitter',
                      style: TextStyle(color: Color(0xFF7C8ED0), fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}