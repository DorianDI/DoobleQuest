import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class ExtincteurForceGamePage extends StatefulWidget {
  const ExtincteurForceGamePage({super.key});

  @override
  State<ExtincteurForceGamePage> createState() =>
      _ExtincteurForceGamePageState();
}

class _ExtincteurForceGamePageState extends State<ExtincteurForceGamePage> {
  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _noiseSubscription;

  bool permissionGranted = false;
  double currentDecibel = 0;
  double maxDecibel = 0;
  bool isBlowing = false;

  final double blowThreshold = 80;

  @override
  void initState() {
    super.initState();
    requestMicrophonePermission();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      setState(() {
        permissionGranted = true;
      });
      startListening();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Permission requise"),
            content: const Text(
                "L'accès au microphone est nécessaire pour ce jeu."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void startListening() async {
    try {
      _noiseSubscription = _noiseMeter.noise.listen(onData, onError: (error) {
        debugPrint("Erreur stream micro: $error");
      });
    } catch (e) {
      debugPrint("Erreur micro: $e");
    }
  }

  void onData(NoiseReading noiseReading) {
    double volume = noiseReading.meanDecibel;

    setState(() {
      currentDecibel = volume;
      isBlowing = volume > blowThreshold;

      // Enregistre le record
      if (volume > maxDecibel) {
        maxDecibel = volume;
      }
    });
  }

  void resetRecord() {
    setState(() {
      maxDecibel = 0;
      currentDecibel = 0;
    });
  }

  String getForceMessage() {
    if (maxDecibel < 70) {
      return "Allez, tu peux souffler plus fort ! 💨";
    } else if (maxDecibel >= 70 && maxDecibel < 80) {
      return "Pas mal ! Continue comme ça 👍";
    } else if (maxDecibel >= 80 && maxDecibel < 90) {
      return "Excellent souffle ! 🔥";
    } else {
      return "INCROYABLE ! Tu es un champion ! 🏆";
    }
  }

  Color getDecibelColor() {
    if (currentDecibel < 80) {
      return Colors.blue;
    } else if (currentDecibel >= 80 && currentDecibel < 90) {
      return Colors.green;
    } else if (currentDecibel >= 90 && currentDecibel < 100) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF63CCE9)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MODE FORCE',
              style: TextStyle(
                color: Color(0xFF63CCE9),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Indicateur visuel du niveau sonore actuel
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getDecibelColor().withOpacity(0.2),
                border: Border.all(
                  color: getDecibelColor(),
                  width: 4,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentDecibel.toStringAsFixed(0),
                      style: TextStyle(
                        color: getDecibelColor(),
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'dB',
                      style: TextStyle(
                        color: getDecibelColor(),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Indicateur si on souffle
            Text(
              isBlowing ? "SOUFFLE 🔥" : "Souffle le plus fort possible",
              style: TextStyle(
                color: isBlowing ? Colors.orange : Colors.white54,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 40),

            // Record
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'RECORD',
                    style: TextStyle(
                      color: Color(0xFF63CCE9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${maxDecibel.toStringAsFixed(1)} dB',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getForceMessage(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Bouton reset
            ElevatedButton(
              onPressed: resetRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF63CCE9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "RÉINITIALISER",
                style: TextStyle(
                  color: Color(0xFF1D132E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}