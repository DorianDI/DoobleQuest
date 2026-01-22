import 'package:flutter/material.dart';
import 'game.dart';

class SquatMinerPage extends StatelessWidget {
  const SquatMinerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Color(0xFFF49A24),
        ),
      ),
      backgroundColor: const Color(0xFF1D132E),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- TON TITRE STYLISÉ ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(-8, 4),
                    child: const Text(
                      'SquatMiner',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 68,
                        color: Color(0xFFF49A24),
                      ),
                    ),
                  ),
                  Text(
                    'SquatMiner',
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
                    'SquatMiner',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFF571D7D),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // --- TA LIGNE DÉCORATIVE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x00F49A24), Color(0xFFF49A24)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Color(0xFFF49A24), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80, height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF49A24), Color(0x00F49A24)],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- AJOUT : L'ILLUSTRATION (Cercle + Mineur) ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260, height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF49A24).withOpacity(0.3),
                          blurRadius: 60,
                        ),
                      ],
                    ),
                  ),
                  ClipOval(
                    child: Image.asset(
                      'assets/img/game/fond_mine.png',
                      width: 260, height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Image.asset(
                    'assets/img/game/gemme.png',
                    width: 180,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- AJOUT : BOUTON DEMARRER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SquatMinerGamePage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFF49A24), width: 1.5),
                      backgroundColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'MINER !',
                      style: TextStyle(fontFamily: 'Bangers', fontSize: 24, color: Color(0xFFF49A24)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- AJOUT : INSTRUCTIONS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFF49A24).withOpacity(0.5)),
                    color: Colors.black.withOpacity(0.1),
                  ),
                  child: const Column(
                    children: [
                      Text('COMMENT JOUER ?', style: TextStyle(fontFamily: 'Bangers', fontSize: 20, color: Color(0xFFF49A24))),
                      SizedBox(height: 10),
                      Text(
                        'Tenez le téléphone bras tendus devant vous. Faites un squat complet pour récolter une gemme ! Pas de temps limite.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFF49A24), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- AJOUT : BOUTON RETOUR ---
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('RETOUR', style: TextStyle(fontFamily: 'Bangers', color: Color(0xFF7C8ED0), fontSize: 20)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}