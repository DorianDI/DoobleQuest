import 'package:flutter/material.dart';

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
                    TextSpan(text: 'Souffle le plus ',
                        style: TextStyle(color: Color(0xFF7C8ED0))),
                    TextSpan(text: 'longtemps/fort ',
                        style: TextStyle(color: Color(0xFF63CCE9))),
                    TextSpan(
                        text: 'possible !', style: TextStyle(color: Color(0xFF7C8ED0))),
                  ],
                ),
              ),
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
                  "Mode Timer, Soufflez jusqu’a ce que le feu s’éteigne. Mode Force, Soufflez le plus fort possible pendant 5 seconde.",
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