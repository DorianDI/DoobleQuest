import 'package:flutter/material.dart';

class FlashMcClouPage extends StatefulWidget {
  const FlashMcClouPage({super.key});

  @override
  State<FlashMcClouPage> createState() => _FlashMcClouPageState();
}

class _FlashMcClouPageState extends State<FlashMcClouPage> {
  bool _showPlayerChoice = false;

  void _onPlay() {
    setState(() => _showPlayerChoice = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Color(0xFF63CCE9),
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
                    'FlashMcClou',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFF663A00),
                    ),
                  ),
                ),
                const Text(
                  'FlashMcClou',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 68,
                    color: Color(0xFF63CCE9),
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
                    TextSpan(text: 'Clou le plus ',
                        style: TextStyle(color: Color(0xFF7C8ED0))),
                    TextSpan(text: 'vite ',
                        style: TextStyle(color: Color(0xFF63CCE9))),
                    TextSpan(
                        text: '!', style: TextStyle(color: Color(0xFF7C8ED0))),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            CustomPaint(
              size: const Size(120, 300), // taille de la zone de dessin
              painter: NailPainter(),
            ),
            SizedBox(height: 50),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _mainMenu(),
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
            border: Border.all(color: Color(0xFF63CCE9)),
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
                          color: Color(0xFF652208),
                        ),
                      ),
                    ),
                    const Text(
                      'Comment jouer ?',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 20,
                        color: Color(0xFF63CCE9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),  // Léger padding
                child: Text(
                  "Tenez le téléphone comme un marteau et frappez  dans l'air! Chaque mouvement compte comme  un coup. Le plus rapide à enfoncer le clou gagne!",
                  style: TextStyle(color: Color(0xFF63CCE9), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
          backgroundColor: const Color(0xFF63CCE9).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFF63CCE9),
          elevation: 0,
          side: const BorderSide(color: Color(0xFF63CCE9), width: 1),
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

class NailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = Color(0xFF63CCE9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Dimensions relatives
    final headHeight = size.height * 0.06;

    final shaftWidth = size.width * 0.20;
    final shaftLeft = (size.width - shaftWidth) / 2;

    // Hauteur réelle de la tige + position du bas de tige
    final shaftHeight = size.height * 0.75;
    final shaftBottom = headHeight + shaftHeight;

    // TÊTE DU CLOU
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.15,
          0,
          size.width * 0.7,
          headHeight,
        ),
        const Radius.circular(8),
      ),
    );

    // TIGE
    path.addRect(
      Rect.fromLTWH(
        shaftLeft,
        headHeight,
        shaftWidth,
        shaftHeight,
      ),
    );

    // POINTE (✅ alignée exactement sur le bas de la tige)
    path.moveTo(shaftLeft, shaftBottom);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(shaftLeft + shaftWidth, shaftBottom);
    path.close();

    // Dessin
    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}