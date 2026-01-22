import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class ExtincteurTimerGamePage extends StatefulWidget {
  const ExtincteurTimerGamePage({super.key});

  @override
  State<ExtincteurTimerGamePage> createState() =>
      _ExtincteurTimerGamePageState();
}

class _ExtincteurTimerGamePageState extends State<ExtincteurTimerGamePage> {
  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _noiseSubscription;

  bool isBlowing = false;
  bool permissionGranted = false;
  bool hasFinished = false; // Nouveau : pour savoir si on a fini

  double currentTime = 0;
  Timer? timer;

  final double blowThreshold = 67.5;

  @override
  void initState() {
    super.initState();
    requestMicrophonePermission();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    timer?.cancel();
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
    // Si on a déjà fini, on n'écoute plus le micro
    if (hasFinished) return;

    double volume = noiseReading.meanDecibel;

    if (volume > blowThreshold && !isBlowing) {
      startTimer();
    }

    if (volume < blowThreshold && isBlowing) {
      stopTimer();
    }
  }

  void startTimer() {
    isBlowing = true;

    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        currentTime += 0.1;
      });
    });
  }

  void stopTimer() {
    setState(() {
      isBlowing = false;
      hasFinished = true; // On marque qu'on a fini
    });
    timer?.cancel();
  }

  void resetTimer() {
    setState(() {
      currentTime = 0;
      isBlowing = false;
      hasFinished = false;
    });
  }

  String formatTime(double time) {
    return time.toStringAsFixed(1);
  }

  String getMessageBasedOnTime() {
    if (!hasFinished) {
      return isBlowing ? "SOUFFLE 🔥" : "Souffle pour démarrer";
    }

    // Messages selon le temps
    if (currentTime < 5) {
      return "Trop court vous avez fini carbonisez 🔥";
    } else if (currentTime >= 5 && currentTime < 15) {
      return "De justesse ! vous etes brulé a certain endroit 🔥";
    } else if (currentTime >= 15 && currentTime < 30) {
      return "Bien joué ! le feu c'est éteint avant que quelqu'un soit blesser 🏆";
    } else {
      return "Excellent ! Tu es un champion ! 🏆";
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
              "MODE TIMER",
              style: TextStyle(
                color: Color(0xFF63CCE9),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "${formatTime(currentTime)} s",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              getMessageBasedOnTime(),
              style: TextStyle(
                color: isBlowing ? Colors.orange : Colors.white54,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),

            // Bouton de reset qui apparaît quand on a fini
            if (hasFinished) ...[
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: resetTimer,
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
                  "RECOMMENCER",
                  style: TextStyle(
                    color: Color(0xFF1D132E),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}