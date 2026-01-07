import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/camillekaze/accueil.dart';
import 'game/tirecowboy/accueil.dart';
import 'game/extincteur/accueil.dart';
import 'game/flashmcclou/accueil.dart';
import 'game/rockybalbobo/accueil.dart';
import 'game/squatminer/accueil.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1D132E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<(String, Widget)> games = [
    ('assets/img/TireCowBoy.png', const TireCowboyPage()),
    ('assets/img/CamilleKaze.png', const CamilleKazePage()),
    ('assets/img/FlashMcClou.png', const FlashMcClouPage()),
    ('assets/img/Extincteur.png', const ExtincteurPage()),
    ('assets/img/SquatMiner.png', const SquatMinerPage()),
    ('assets/img/RockyBalBoBo.png', const RockyBalBoBoPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Stack(
              children: [
                Transform.translate(
                  offset: const Offset(-8, 4),
                  child: Text(
                    'Doodle Quest',
                    style: const TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFFF49A24),
                    ),
                  ),
                ),
                Text(
                  'Doodle Quest',
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
                  'Doodle Quest',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: 68,
                    color: Color(0xFF571D7D),
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
                    TextSpan(text: 'Are you a ', style: TextStyle(color: Color(0xFF7C8ED0))),
                    TextSpan(text: 'looser ', style: TextStyle(color: Color(0xFFF49A24))),
                    TextSpan(text: '?', style: TextStyle(color: Color(0xFF7C8ED0))),
                  ],
                ),
              ),
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 15,
              childAspectRatio: 1.10,
              children: [
                for (final g in games) _gridItem(context, g.$1, g.$2),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget _gridItem(BuildContext context, String path, Widget page) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Center(
            child: SizedBox(
              width: 160,
              child: Image.asset(path, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    ),
  );
}
