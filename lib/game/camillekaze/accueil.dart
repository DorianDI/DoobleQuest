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
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFF49A24)),
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
                      color: Color(0xFFF49A24),
                    ),
                  ),
                ),
                Text(
                  'CamilleKaze',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 68,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.black,
                  ),
                ),
                const Text(
                  'CamilleKaze',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 68,
                    color: Color(0xFF571D7D),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0x00F49A24),
                        Color(0xFFF49A24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF49A24),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFF49A24),
                        Color(0x00F49A24),
                      ],
                    ),
                  ),
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
          label: 'PLAY',
           onTap: _onPlay,
        ),
        const SizedBox(height: 12),
        //_bigButton(
        //  label: 'HISTORIQUE',
        //  onTap: () {
            // TODO: page historique plus tard
        //    ScaffoldMessenger.of(context).showSnackBar(
        //      const SnackBar(content: Text('Historique bientôt 👀')),
        //    );
        //  },
        //),
        //SizedBox(height: 12),
        _bigButton(
          label: 'RÈGLES',
          onTap: _showRules,
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
                builder: (_) => const CamilleKazeGamePage(minSeconds: 20, maxSeconds: 30),
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
                builder: (_) => const CamilleKazeGamePage(minSeconds: 40, maxSeconds: 55),
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
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF571D7D),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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

  void _showRules() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D132E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Règles — CamilleKaze', style: TextStyle(fontFamily: 'Bangers', fontSize: 28, color: Color(0xFFF49A24))),
                SizedBox(height: 12),
                Text('• Une bombe est affichée à l’écran.'),
                Text('• Elle explose après un temps aléatoire.'),
                Text('• Les joueurs se passent le téléphone : celui qui l’a quand ça explose perd la manche.'),
                Text('• Si le téléphone est donné trop brusquement → explosion immédiate.'),
                SizedBox(height: 12),
                Text('Temps :'),
                Text('• Mode 1–5 joueurs : explosion entre 20s et 30s.'),
                Text('• Mode 5–15 joueurs : explosion entre 40s et 55s.'),
              ],
            ),
          ),
        );
      },
    );
  }
}
