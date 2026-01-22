import 'package:flutter/material.dart';
import 'game.dart';

class TireCowboyPage extends StatelessWidget {
  const TireCowboyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF49A24)),
      ),
      backgroundColor: const Color(0xFF1D132E),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(-8, 3),
                    child: const Text(
                      'Tire, CowBoy !',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 68,
                        color: Color(0xC3A1620E),
                      ),
                    ),
                  ),
                  const Text(
                    'Tire, CowBoy !',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFFF49A24),
                    ),
                  ),
                ],
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontFamily: 'Caveat', fontSize: 32),
                  children: [
                    TextSpan(text: 'Dégaine le plus ', style: TextStyle(color: Color(0xFF7C8ED0))),
                    TextSpan(text: 'vite !', style: TextStyle(color: Color(0xFFF49A24))),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildDecorativeLine(),

              const SizedBox(height: 40),

              _buildCentralIllustration(),

              const SizedBox(height: 40),

              // BOUTON SOLO
              _buildStartButton(context, 'SOLO', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TireCowboyGamePage()));
              }),

              const SizedBox(height: 15),

              const SizedBox(height: 40),

              _buildInstructions(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _gradientLine(true),
        const SizedBox(width: 8),
        Container(width: 15, height: 15, decoration: const BoxDecoration(color: Color(0xFFF49A24), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        _gradientLine(false),
      ],
    );
  }

  Widget _gradientLine(bool reverse) {
    return Container(
      width: 70, height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse ? [const Color(0x00F49A24), const Color(0xFFF49A24)] : [const Color(0xFFF49A24), const Color(0x00F49A24)],
        ),
      ),
    );
  }

  Widget _buildCentralIllustration() {
    return SizedBox(
      width: 280, height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFFF49A24).withValues(alpha: 0.3), blurRadius: 50, spreadRadius: 10)],
            ),
          ),
          ClipOval(
            child: Image.asset('assets/img/game/cowboy_bg.png', width: 250, height: 250, fit: BoxFit.cover),
          ),
          Image.asset('assets/img/game/cowboy_gun.png', width: 200, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFF49A24), width: 1.5),
            backgroundColor: Colors.black.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(label, style: const TextStyle(fontFamily: 'Bangers', fontSize: 24, color: Color(0xFFF49A24))),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFF49A24).withValues(alpha: 0.5)),
          color: Colors.black.withValues(alpha: 0.1),
        ),
        child: const Column(
          children: [
            Text('COMMENT JOUER ?', style: TextStyle(fontFamily: 'Bangers', fontSize: 20, color: Color(0xFFF49A24))),
            SizedBox(height: 10),
            Text(
              'Tenez votre téléphone comme un pistolet vers le bas. Attendez 12 secondes, puis dégainez en levant rapidement le téléphone au signal !',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFF49A24), fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
  
}