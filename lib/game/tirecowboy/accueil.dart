import 'package:flutter/material.dart';

class TireCowboyPage extends StatelessWidget {
  const TireCowboyPage({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Transform.translate(
                  offset: const Offset(-8, 4),
                  child: Text(
                    'TireCowBoy',
                    style: const TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFFF49A24),
                    ),
                  ),
                ),
                Text(
                  'TireCowBoy',
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
                  'TireCowBoy',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 68,
                    color: Color(0xFF571D7D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15,),
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
                        Color(0x00F49A24), // transparent
                        Color(0xFFF49A24), // plein
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
          ],
        ),
      ),
    );
  }
}
