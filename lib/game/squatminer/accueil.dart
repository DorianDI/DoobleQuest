import 'package:flutter/material.dart';
// Assurez-vous que ce fichier existe et contient SquatMinerGamePage
import 'game.dart';

class SquatMinerPage extends StatefulWidget {
  const SquatMinerPage({super.key});

  @override
  State<SquatMinerPage> createState() => _SquatMinerPageState();
}

class _SquatMinerPageState extends State<SquatMinerPage> {
  // Définition des couleurs principales de la maquette
  final Color _neonGreen = const Color(0xFF39FF14); // Vert fluo pour le texte et les bordures
  final Color _darkGreenButton = const Color(0xFF1A3311); // Vert foncé pour le fond du bouton

  void _onPlay() {
    // Navigation vers la page de jeu (assurez-vous que SquatMinerGamePage existe dans game.dart)
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SquatMinerGamePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond foncée de la maquette
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: _neonGreen, // Icône retour en vert fluo
        ),
      ),
      body: SafeArea(
        // Utilisation de SingleChildScrollView pour éviter les dépassements sur petits écrans
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- TITRE PRINCIPAL ---
              Stack(
                children: [
                  // Ombre/Contour du texte
                  Transform.translate(
                    offset: const Offset(-4, 4),
                    child: Text(
                      'SQUAT MINER',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 68,
                        // Un vert très foncé pour l'ombre
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  // Texte principal vert fluo
                  Text(
                    'SQUAT MINER',
                    style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 68,
                        color: _neonGreen,
                        shadows: [
                          Shadow(blurRadius: 10, color: _neonGreen.withOpacity(0.5))
                        ]
                    ),
                  ),
                ],
              ),

              // --- SOUS-TITRE RICHTEXT ---
              Transform.translate(
                offset: const Offset(-8, 4),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Caveat', // Ou une autre police manuscrite si celle-ci ne correspond pas exactement
                      fontSize: 28,
                      color: Colors.white, // Couleur par défaut blanche
                    ),
                    children: [
                      const TextSpan(text: 'Ramasse le plus de '),
                      TextSpan(
                          text: 'gemme ',
                          // Mot clé en vert fluo
                          style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'possible !'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- VISUEL CENTRAL (Cercle Mine + Gemme) ---
              // Remplacement du CustomPaint (clou) par une Stack d'images
              Stack(
                alignment: Alignment.center,
                children: [
                  // Effet de lueur verte derrière le cercle
                  Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _neonGreen.withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // L'image de fond de la mine, découpée en cercle
                  ClipOval(
                    child: Image.asset(
                      'assets/img/game/fond_mine.png', // Chemin à adapter selon votre projet
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // L'image de la gemme par-dessus
                  Image.asset(
                    'assets/img/game/gemme.png', // Chemin à adapter selon votre projet
                    width: 200, // Ajustez la taille selon votre image
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- MENU PRINCIPAL ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                // Utilisation d'une transition fluide si le menu change
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _mainMenu(),
                ),
              ),
              const SizedBox(height: 20),
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
        // Bouton DEMARRER
        _bigButton(
          label: 'DEMARRER !',
          onTap: _onPlay,
        ),
        const SizedBox(height: 30),

        // --- BOITE "COMMENT JOUER" ---
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3), // Fond légèrement plus foncé
            borderRadius: BorderRadius.circular(15),
            // Bordure vert fluo
            border: Border.all(color: _neonGreen, width: 2),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Titre de la boîte
              Text(
                'COMMENT JOUER ?',
                style: TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 22,
                  color: _neonGreen, // Titre en vert fluo
                ),
              ),
              const SizedBox(height: 5),
              // Texte explicatif
              const Padding(
                padding: EdgeInsets.only(bottom: 15, left: 15, right: 15),
                child: Text(
                  "Tenez le téléphone bras tendus devant vous et faites des squats! Chaque squat ramasse une gemme. Si vous ne descendez pas assez bas vous ne récolterez pas de gemme !",
                  style: TextStyle(
                      color: Colors.white70, // Texte blanc cassé pour la lisibilité
                      fontSize: 14,
                      height: 1.3
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget de bouton personnalisé adapté à la nouvelle charte graphique
  Widget _bigButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Bouton légèrement plus haut
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          // Couleur de fond vert foncé
          backgroundColor: _darkGreenButton,
          // Couleur du texte vert fluo
          foregroundColor: _neonGreen,
          elevation: 5,
          shadowColor: _neonGreen.withOpacity(0.3),
          // Bordure vert fluo
          side: BorderSide(color: _neonGreen, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontFamily: 'Bangers',
              fontSize: 24,
              letterSpacing: 2,
              fontStyle: FontStyle.italic // Ajout de l'italique comme sur la maquette
          ),
        ),
      ),
    );
  }
}

// Le NailPainter a été supprimé car il n'est plus utilisé dans cette maquette.