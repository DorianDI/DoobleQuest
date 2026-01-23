import 'package:flutter/material.dart';
import 'multiplayer_service.dart';
import 'multiplayer_lobby.dart';

class MultiplayerMenuPage extends StatefulWidget {
  const MultiplayerMenuPage({super.key});

  @override
  State<MultiplayerMenuPage> createState() => _MultiplayerMenuPageState();
}

class _MultiplayerMenuPageState extends State<MultiplayerMenuPage> {
  final MultiplayerService _service = MultiplayerService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // serveur render
  static const String serverUrl = 'https://dooblequestserver.onrender.com';

  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    setState(() => _isConnecting = true);
    
    _service.connect(serverUrl);
    
    // Attendre un peu pour la connexion
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    });

    _service.onGameCreated = (gameCode) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerLobbyPage(
            isHost: true,
            gameCode: gameCode,
          ),
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

  void _createGame() {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrez votre nom !'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_service.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion au serveur en cours...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _service.createGame(name);
  }

  void _joinGame() {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrez votre nom !'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrez le code de partie !'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_service.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion au serveur en cours...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _service.joinGame(code, name);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiplayerLobbyPage(
          isHost: false,
          gameCode: code,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _service.onGameCreated = null;
    _service.onError = null;
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
        title: const Text(
          'Multijoueur',
          style: TextStyle(
            fontFamily: 'Bangers',
            color: Color(0xFFF49A24),
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF1D132E),
      body: _isConnecting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFF49A24)),
                  SizedBox(height: 20),
                  Text(
                    'Connexion au serveur...',
                    style: TextStyle(
                      color: Color(0xFFF49A24),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Statut de connexion
                  _buildConnectionStatus(),

                  const SizedBox(height: 40),

                  // Champ nom
                  _buildTextField(
                    controller: _nameController,
                    label: 'Votre nom',
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 40),

                  // Bouton créer une partie
                  _buildActionButton(
                    label: 'CRÉER UNE PARTIE',
                    icon: Icons.add_circle_outline,
                    onPressed: _createGame,
                  ),

                  const SizedBox(height: 30),

                  // Diviseur
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: const Color(0xFFF49A24).withValues(alpha: 0.3))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Color(0xFFF49A24),
                            fontFamily: 'Bangers',
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: const Color(0xFFF49A24).withValues(alpha: 0.3))),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Champ code de partie
                  _buildTextField(
                    controller: _codeController,
                    label: 'Code de partie',
                    icon: Icons.key,
                    uppercase: true,
                  ),

                  const SizedBox(height: 20),

                  // Bouton rejoindre une partie
                  _buildActionButton(
                    label: 'REJOINDRE',
                    icon: Icons.login,
                    onPressed: _joinGame,
                    isPrimary: false,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionStatus() {
    final isConnected = _service.isConnected;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isConnected 
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error,
            color: isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isConnected ? 'Connecté au serveur' : 'Déconnecté',
            style: TextStyle(
              color: isConnected ? Colors.green : Colors.red,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool uppercase = false,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.words,
      style: const TextStyle(
        color: Color(0xFFF49A24),
        fontSize: 18,
        fontFamily: 'Bangers',
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF7C8ED0),
          fontFamily: 'Bangers',
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFF49A24)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF49A24), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF49A24), width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFFF49A24),
            width: isPrimary ? 2 : 1.5,
          ),
          backgroundColor: isPrimary 
              ? const Color(0xFFF49A24).withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFF49A24)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Bangers',
                fontSize: 24,
                color: Color(0xFFF49A24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
