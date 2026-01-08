import 'package:flutter/material.dart';
import 'game.dart';

class CamilleKazePage extends StatefulWidget {
  const CamilleKazePage({super.key});

  @override
  State<CamilleKazePage> createState() => _CamilleKazePageState();
}

class _CamilleKazePageState extends State<CamilleKazePage> {
  bool _showPlayerChoice = false;

  void _onPlay() {
    setState(() => _showPlayerChoice = true);
  }

  void _onBackToMenu() {
    setState(() => _showPlayerChoice = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Color(0xFFF49A24),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Transform.translate(
                  offset: const Offset(-8, 4),
                  child: const Text(
                    'CamilleKaze',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFF663A00),
                    ),
                  ),
                ),
                const Text(
                  'CamilleKaze',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 68,
                    color: Color(0xFFF84C08),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(-8, 4),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 36,
                  ),
                  children: [
                    TextSpan(text: 'Passe la ',
                        style: TextStyle(color: Color(0xFF7C8ED0))),
                    TextSpan(text: 'Bombe ',
                        style: TextStyle(color: Color(0xFFF84C08))),
                    TextSpan(
                        text: '!', style: TextStyle(color: Color(0xFF7C8ED0))),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFFF84C08),
                          blurRadius: 100,
                          spreadRadius: 5
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1D132E),
                    border: Border.all(
                      color: Color(0xFFF84C08),
                      width: 1,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/img/game/bombe.png',
                  width: 210,
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: 50),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _showPlayerChoice
                        ? _playerChoice()
                        : _mainMenu(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainMenu() {
    return Column(
      key: const ValueKey('mainMenu'),
      children: [
        _bigButton(
          label: 'DEMARRER !',
          onTap: _onPlay,
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFFF84C08)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: const Offset(-2, 3),
                      child: const Text(
                        'Comment jouer ?',
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: 20,
                          color: Color(0xFF663A00),
                        ),
                      ),
                    ),
                    const Text(
                      'Comment jouer ?',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 20,
                        color: Color(0xFFF84C08),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),  // Léger padding
                child: Text(
                  "La bombe va exploser! Passez le téléphone à un ami avant la fin du temps. Attention: Si vous le passez trop vite, la bombe explose immédiatement!",
                  style: TextStyle(color: Color(0xFFF84C08), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _playerChoice() {
    return Column(
      key: const ValueKey('playerChoice'),
      children: [
        _bigButton(
          label: '1 - 5 JOUEURS',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const CamilleKazeGamePage(minSeconds: 20, maxSeconds: 30),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _bigButton(
          label: '5 - 15 JOUEURS',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const CamilleKazeGamePage(minSeconds: 40, maxSeconds: 55),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _onBackToMenu,
          child: const Text(
            'Retour',
            style: TextStyle(color: Color(0xFF7C8ED0)),
          ),
        ),
      ],
    );
  }

  Widget _bigButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF84C08).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFFF84C08),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFF84C08), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Bangers',
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}