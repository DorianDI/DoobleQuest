import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // fond transparent
      statusBarIconBrightness: Brightness.light, // ANDROID → icônes blanches
      statusBarBrightness: Brightness.dark, // iOS → texte blanc
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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
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
                    'Dooble Quest',
                    style: const TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 68,
                      color: Color(0xFFF49A24),
                    ),
                  ),
                ),
                Text(
                  'Dooble Quest',
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
                  'Dooble Quest',
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
            SizedBox(height: 30,),
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
