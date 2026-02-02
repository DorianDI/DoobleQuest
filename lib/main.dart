import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/camillekaze/accueil.dart';
import 'game/tirecowboy/accueil.dart';
import 'game/extincteur/accueil.dart';
import 'game/flashmcclou/accueil.dart';
import 'game/rockybalbobo/accueil.dart';
import 'game/squatminer/accueil.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/medecin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  bool _isLoggedIn = false;

  final List<(String, Widget)> games = [
    ('assets/img/TireCowBoy.png', const TireCowboyPage()),
    ('assets/img/CamilleKaze.png', const CamilleKazePage()),
    ('assets/img/FlashMcClou.png', const FlashMcClouPage()),
    ('assets/img/Extincteur.png', const ExtincteurPage()),
    ('assets/img/SquatMiner.png', const SquatMinerPage()),
    ('assets/img/RockyBalBoBo.png', const RockyBalBoBoPage()),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _handleLoginOrMedecinPage() async {
    if (_isLoggedIn) {
      // Si connecté, aller vers la page médecin
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedecinPage()),
      );

      // Si l'utilisateur s'est déconnecté, rafraîchir le statut
      if (result == true) {
        await _checkLoginStatus();
      }
    } else {
      // Si non connecté, aller vers la page de connexion
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

      // Si connexion réussie, rafraîchir le statut
      if (result == true) {
        await _checkLoginStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(-8, 4),
                    child: const Text(
                      'Doodle Quest',
                      style: TextStyle(
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
              const SizedBox(height: 15),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.10,
                  children: [
                    for (final g in games) _gridItem(context, g.$1, g.$2),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Bouton de connexion ou accès page médecin
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLoginOrMedecinPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoggedIn
                          ? const Color(0xFF571D7D)
                          : const Color(0xFFF49A24),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLoggedIn ? Icons.dashboard : Icons.medical_services,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLoggedIn ? 'Page Médecin' : 'Connexion Médecin',
                          style: const TextStyle(
                            fontFamily: 'Bangers',
                            fontSize: 20,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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