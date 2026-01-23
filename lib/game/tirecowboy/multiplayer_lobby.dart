import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'multiplayer_service.dart';
import 'multiplayer_game.dart';

class MultiplayerLobbyPage extends StatefulWidget {
  final bool isHost;
  final String? gameCode;

  const MultiplayerLobbyPage({
    super.key,
    required this.isHost,
    this.gameCode,
  });

  @override
  State<MultiplayerLobbyPage> createState() => _MultiplayerLobbyPageState();
}

class _MultiplayerLobbyPageState extends State<MultiplayerLobbyPage> {
  final MultiplayerService _service = MultiplayerService();
  
  String? _gameCode;
  bool _isReady = false;
  bool _opponentReady = false;
  String? _opponentName;
  String? _hostName;
  String? _guestName;

  @override
  void initState() {
    super.initState();
    _gameCode = widget.gameCode;
    _setupListeners();
  }

  void _setupListeners() {
    _service.onPlayerJoined = (players) {
      setState(() {
        _hostName = players['host']['name'];
        _guestName = players['guest']?['name'];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${players['guest']['name']} a rejoint la partie !'),
          backgroundColor: const Color(0xFFF49A24),
        ),
      );
    };

    _service.onRematchRead= (players) {
      setState(() {
        _hostName = players['host']['name'];
        _guestName = players['guest']?['name'];
        _isReady = false;
        _opponentReady = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prêts pour un nouveau duel !'),
          backgroundColor: Color(0xFFF49A24),
          duration: Duration(seconds: 2),
        ),
      );
    };

    _service.onWaitingForPlayers = (hostReady, guestReady) {
      setState(() {
        if (widget.isHost) {
          _isReady = hostReady;
          _opponentReady = guestReady;
        } else {
          _isReady = guestReady;
          _opponentReady = hostReady;
        }
      });
    };

    _service.onGameStarting = (delay) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerGamePage(
            gameCode: _gameCode!,
            isHost: widget.isHost,
          ),
        ),
      );
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

    _service.onError = (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    };
  }

  void _toggleReady() {
    if (_guestName == null && widget.isHost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En attente d\'un adversaire...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isReady = !_isReady;
    });

    if (_isReady) {
      _service.playerReady();
    }
  }

  void _copyGameCode() {
    if (_gameCode != null) {
      Clipboard.setData(ClipboardData(text: _gameCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copié dans le presse-papier !'),
          backgroundColor: Color(0xFFF49A24),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _service.onPlayerJoined = null;
    _service.onWaitingForPlayers = null;
    _service.onGameStarting = null;
    _service.onPlayerLeft = null;
    _service.onError = null;
    _service.onRematchRead = null;
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
        title: const Text(
          'Lobby',
          style: TextStyle(
            fontFamily: 'Bangers',
            color: Color(0xFFF49A24),
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF1D132E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Code de partie
              if (widget.isHost && _gameCode != null) ...[
                const Text(
                  'CODE DE PARTIE',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 20,
                    color: Color(0xFF7C8ED0),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _copyGameCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      border: Border.all(color: const Color(0xFFF49A24), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _gameCode!,
                          style: const TextStyle(
                            fontFamily: 'Bangers',
                            fontSize: 36,
                            color: Color(0xFFF49A24),
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.copy, color: Color(0xFFF49A24)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Appuyez pour copier',
                  style: TextStyle(
                    color: Color(0xFF7C8ED0),
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Liste des joueurs
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayerCard(
                      name: widget.isHost ? _hostName ?? _service.playerName ?? 'Joueur 1' : _guestName ?? _service.playerName ?? 'Joueur 2',
                      isReady: _isReady,
                      isYou: true,
                    ),
                    const SizedBox(height: 30),
                    const Icon(Icons.flash_on, color: Color(0xFFF49A24), size: 40),
                    const SizedBox(height: 30),
                    _buildPlayerCard(
                      name: widget.isHost ? (_guestName ?? 'En attente...') : (_hostName ?? 'Adversaire'),
                      isReady: _opponentReady,
                      isYou: false,
                      isWaiting: _guestName == null && widget.isHost,
                    ),
                  ],
                ),
              ),

              // Bouton Prêt
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _toggleReady,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isReady ? Colors.green : const Color(0xFFF49A24),
                      width: 2,
                    ),
                    backgroundColor: _isReady 
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isReady ? 'PRÊT ✓' : 'PRÊT ?',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 28,
                      color: _isReady ? Colors.green : const Color(0xFFF49A24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required bool isReady,
    required bool isYou,
    bool isWaiting = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: isReady ? Colors.green : const Color(0xFFF49A24).withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isReady ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
              border: Border.all(
                color: isReady ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isWaiting ? Icons.hourglass_empty : (isReady ? Icons.check : Icons.person),
                color: isReady ? Colors.green : Colors.grey,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 22,
                    color: Color(0xFFF49A24),
                  ),
                ),
                Text(
                  isYou ? '(Vous)' : '',
                  style: const TextStyle(
                    color: Color(0xFF7C8ED0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isReady)
            const Icon(Icons.check_circle, color: Colors.green, size: 30),
        ],
      ),
    );
  }
}
