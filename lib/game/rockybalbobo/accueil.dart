import 'package:flutter/material.dart';
import 'game.dart'; // Assure-toi que ton fichier avec RockyCameraView est bien importé

class RockyBalBoBoPage extends StatefulWidget {
  const RockyBalBoBoPage({super.key});

  @override
  State<RockyBalBoBoPage> createState() => _RockyBalBoBoPageState();
}

class _RockyBalBoBoPageState extends State<RockyBalBoBoPage> {
  // Couleur rouge de la maquette
  final Color rockyRed = const Color(0xFFD11F41);

  void _onPlay() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RockyCameraView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: rockyRed,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- TITRE ---
              Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(-4, 4),
                    child: const Text(
                      'ROCKY BALBOBO',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 60,
                        color: Color(0xFF651323), // Ombre foncée
                      ),
                    ),
                  ),
                  Text(
                    'ROCKY BALBOBO',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 60,
                      color: rockyRed,
                    ),
                  ),
                ],
              ),

              // --- SOUS-TITRE ---
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 32,
                  ),
                  children: [
                    TextSpan(text: 'Boxe jusqu’au ', style: TextStyle(color: Colors.white70)),
                    TextSpan(text: 'K.O. !', style: TextStyle(color: Color(0xFFD11F41))),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- VISUEL CENTRAL (STACK MINE STYLE) ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle extérieur brillant
                  Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: rockyRed.withValues(alpha : 0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Image de fond (Le Ring)
                  ClipOval(
                    child: Image.asset(
                      'assets/img/game/ring.png',
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Image de devant (Le Gant)
                  Image.asset(
                    'assets/img/game/gant.png',
                    width: 180,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- MENU ET BOUTONS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _mainMenu(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainMenu() {
    return Column(
      children: [
        _bigButton(
          label: 'DEMARRER !',
          onTap: _onPlay,
        ),
        const SizedBox(height: 25),

        // --- BOITE COMMENT JOUER ---
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha : 0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: rockyRed, width: 1.5),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'COMMENT JOUER ?',
                style: TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 22,
                  color: Color(0xFFD11F41),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
                child: Text(
                  "Posez le téléphone et tenez-vous DE PROFIL face à la caméra. Donnez des coups de poing rapides pour marquer des points ! Revenez bien en garde entre chaque coup.",
                  style: TextStyle(color: Colors.white.withValues(alpha : 0.7), fontSize: 14),
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
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: rockyRed.withValues(alpha : 0.1),
          foregroundColor: rockyRed,
          elevation: 0,
          side: BorderSide(color: rockyRed, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Bangers',
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}