import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'multiplayer_service.dart';
import 'multiplayer_lobby.dart';

class MultiplayerGamePage extends StatefulWidget {
  final String gameCode;
  final bool isHost;

  const MultiplayerGamePage({
    super.key,
    required this.gameCode,
    required this.isHost,
  });

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  static const double sensitivity = 28.0;

  final MultiplayerService _service = MultiplayerService();
  final AudioPlayer _gunShoot = AudioPlayer();

  bool _isWaiting = true;
  bool _isGameOver = false;
  String _message = "NE BOUGE PAS...";

  DateTime? _signalTime;
  int? _myReactionTime;
  int? _opponentReactionTime;
  String? _opponentName;
  bool _iHaveFaulStart = false;
  bool _opponentHasFaulStart = false;

  StreamSubscription? _accelSub;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _startAccelerometer();
  }

  void _setupListeners() {
    _service.onShootNow = () {
      if (!_isGameOver) {
        setState(() {
          _isWaiting = false;
          _message = "TIRE !";
          _signalTime = DateTime.now();
        });
        // 🔥 Vibrations plus intenses et plus longues
        Future.wait([
          HapticFeedback.heavyImpact(),
          Future.delayed(const Duration(milliseconds: 50), () => HapticFeedback.heavyImpact()),
          Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.heavyImpact()),
          Future.delayed(const Duration(milliseconds: 150), () => HapticFeedback.heavyImpact()),
          Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact()),
          Future.delayed(const Duration(milliseconds: 250), () => HapticFeedback.heavyImpact()),
        ]);
      }
    };

    _service.onPlayerShot = (data) {
      final isMe = (widget.isHost && data['isHost']) || (!widget.isHost && !data['isHost']);

      setState(() {
        if (isMe) {
          if (data['faulStart'] == true) {
            _iHaveFaulStart = true;
            _message = "TROP TÔT !";
          } else {
            _myReactionTime = data['reactionTime'];
          }
        } else {
          _opponentName = data['playerName'];

          if (data['faulStart'] == true) {
            _opponentHasFaulStart = true;
          } else {
            _opponentReactionTime = data['reactionTime'];
          }
        }
      });
    };

    _service.onGameOver = (result) {
      setState(() {
        _isGameOver = true;

        if (result['result'] == 'both_fault') {
          _message = "FAUX DÉPART\ndes deux côtés !";
        } else if (result['result'] == 'draw') {
          _message = "ÉGALITÉ !";
        } else if (result['result'] == 'host_wins') {
          if (widget.isHost) {
            _message = "VICTOIRE !\n${_myReactionTime} ms";
          } else {
            _message = "DÉFAITE\n${_opponentReactionTime} ms";
          }
        } else if (result['result'] == 'guest_wins') {
          if (!widget.isHost) {
            _message = "VICTOIRE !\n${_myReactionTime} ms";
          } else {
            _message = "DÉFAITE\n${_opponentReactionTime} ms";
          }
        }
      });
    };

    _service.onPlayerLeft = (socketId) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'adversaire a quitté la partie'),
          backgroundColor: Colors.red,
        ),
      );
    };
  }

  void _startAccelerometer() {
    _accelSub = accelerometerEventStream().listen((event) {
      if (_isGameOver || _myReactionTime != null) return;

      final force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (force > sensitivity) {
        _handleShoot();
      }
    });
  }

  Future<void> _playShotSound() async {
    try {
      await _gunShoot.play(AssetSource('sfx/gun_shoot.mp3'));
    } catch (e) {
      debugPrint("Erreur son : $e");
    }
  }

  void _handleShoot() {
    if (_isWaiting) {
      // Faux départ
      setState(() {
        _iHaveFaulStart = true;
        _message = "TROP TÔT !";
      });
      _service.playerShoot(0); // 0 pour indiquer un faux départ
    } else {
      // Tir valide
      final now = DateTime.now();
      final reactionTime = now.difference(_signalTime!).inMilliseconds;

      setState(() {
        _myReactionTime = reactionTime;
      });

      _playShotSound();
      _service.playerShoot(reactionTime);
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gunShoot.dispose();
    _service.onShootNow = null;
    _service.onPlayerShot = null;
    _service.onGameOver = null;
    _service.onPlayerLeft = null;
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
          onPressed: () {
            _service.leaveGame();
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFF1D132E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image du pistolet
            if (!_isWaiting || _isGameOver)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Image.asset(
                  'assets/img/game/cowboy_gun.png',
                  width: 250,
                ),
              ),

            const SizedBox(height: 30),

            // Message principal
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: 60,
                color: _iHaveFaulStart ? Colors.red : const Color(0xFFF49A24),
              ),
            ),

            const SizedBox(height: 20),

            // Scores
            if (_myReactionTime != null || _opponentReactionTime != null) ...[
              _buildScoreCard(
                'Vous',
                _myReactionTime,
                _iHaveFaulStart,
              ),
              const SizedBox(height: 15),
              _buildScoreCard(
                _opponentName ?? 'Adversaire',
                _opponentReactionTime,
                _opponentHasFaulStart,
              ),
            ],

            // Boutons de fin de partie
            if (_isGameOver) ...[
              const SizedBox(height: 40),
              _actionButton("REJOUER", () {
                // Demander un rematch (réinitialise côté serveur)
                _service.requestRematch();

                // Retourner au lobby avec les mêmes joueurs
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiplayerLobbyPage(
                      isHost: widget.isHost,
                      gameCode: widget.gameCode,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              _actionButton("MENU", () {
                // Quitter complètement la partie
                _service.leaveGame();
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String name, int? reactionTime, bool faulStart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: faulStart
              ? Colors.red
              : (reactionTime != null ? const Color(0xFFF49A24) : Colors.grey),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Bangers',
              fontSize: 20,
              color: Color(0xFFF49A24),
            ),
          ),
          Text(
            faulStart ? 'FAUX DÉPART' : (reactionTime != null ? '$reactionTime ms' : '...'),
            style: TextStyle(
              fontFamily: 'Bangers',
              fontSize: 20,
              color: faulStart ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFF49A24), width: 2),
            backgroundColor: Colors.black.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Bangers',
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}