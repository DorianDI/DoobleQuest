import 'package:flutter/material.dart';
import 'game_timer.dart';
import 'game_force.dart';

class ExtincteurPage extends StatefulWidget {
  const ExtincteurPage({super.key});

  @override
  State<ExtincteurPage> createState() => _ExtincteurPageState();
}

class _ExtincteurPageState extends State<ExtincteurPage> {
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
        iconTheme: const IconThemeData(color: Color(0xFF63CCE9)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(-8, 4),
                    child: const Text(
                      "L'Extincteur",
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 68,
                        color: Color(0xFF663A00),
                      ),
                    ),
                  ),
                  const Text(
                    "L'Extincteur",
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFFB3B3B3),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(-6, 4),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'Caveat', fontSize: 36),
                    children: [
                      TextSpan(
                        text: 'Souffle le plus ',
                        style: TextStyle(color: Color(0xFF7C8ED0)),
                      ),
                      TextSpan(
                        text: 'longtemps/fort ',
                        style: TextStyle(color: Color(0xFFB3B3B3)),
                      ),
                      TextSpan(
                        text: '\npossible !',
                        style: TextStyle(color: Color(0xFF7C8ED0)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.80,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExtincteurTimerGamePage(),
                          ),
                        );
                      },
                      child: const ModeCard(
                        title: "Mode Timer",
                        decorFull: "assets/img/game/feu.png",
                        decorHeight: 100,
                        bottom: -15,
                        scale: 1,
                        fullFit: BoxFit.cover,
                        fullBleed: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  FractionallySizedBox(
                    widthFactor: 0.80,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExtincteurForceGamePage(),
                          ),
                        );
                      },
                      child: ModeCard(
                        title: "Mode Force",
                        decorLeft: "assets/img/game/vent.png",
                        decorRight: "assets/img/game/vent.png",
                        decorHeight: 70,
                        bottom: 20,
                        scale: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _mainMenu(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainMenu() {
    return Column(
      key: const ValueKey('mainMenu'),
      children: [
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFFB3B3B3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
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
                        color: Color(0xFFB3B3B3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  left: 8,
                  right: 8,
                ), // Léger padding
                child: Text(
                  "Mode Timer, Soufflez jusqu’a ce que le feu s’éteigne.\n Mode Force, Soufflez le plus fort possible pendant 5 seconde.",
                  style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 14),
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
          backgroundColor: const Color(0xFFB3B3B3).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFFB3B3B3),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFB3B3B3), width: 1),
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

class ModeCard extends StatelessWidget {
  final String title;

  // décor plein largeur (ex: feu)
  final String? decorFull;

  // décor gauche/droite (ex: tornades)
  final String? decorLeft;
  final String? decorRight;

  final double height;
  final double decorHeight;
  final double bottom;
  final double scale;
  final BoxFit fullFit;

  final bool fullBleed;

  const ModeCard({
    super.key,
    required this.title,
    this.decorFull,
    this.decorLeft,
    this.decorRight,
    this.height = 120,
    this.decorHeight = 60,
    this.bottom = 10,
    this.scale = 1.0,
    this.fullFit = BoxFit.cover,
    this.fullBleed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2B2541),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB3B3B3)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // ✅ décor plein largeur (FEU)
            if (decorFull != null)
              Positioned(
                left: fullBleed ? -20 : 0,
                right: fullBleed ? -20 : 0,
                bottom: bottom,
                height: decorHeight,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    decorFull!,
                    width: double.infinity,
                    height: decorHeight,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),

            if (decorLeft != null)
              Positioned(
                left: 14,
                bottom: bottom,
                width: 70,
                height: decorHeight,
                child: Image.asset(decorLeft!, fit: BoxFit.contain),
              ),

            if (decorRight != null)
              Positioned(
                right: 14,
                bottom: bottom,
                width: 70,
                height: decorHeight,
                child: Image.asset(decorRight!, fit: BoxFit.contain),
              ),

            // Texte centré
            Center(
              child: Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(-2, 2),
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 18,
                        color: Color(0xFF652208),
                      ),
                    ),
                  ),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 18,
                      color: Color(0xFFB3B3B3),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
