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

  double currentTime = 0;
  Timer? timer;

  final double blowThreshold = 75;

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
      // Permission refusée
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
    isBlowing = false;
    timer?.cancel();
  }

  String formatTime(double time) {
    return time.toStringAsFixed(1);
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
              isBlowing ? "SOUFFLE 🔥" : "Souffle pour démarrer",
              style: TextStyle(
                color: isBlowing ? Colors.orange : Colors.white54,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}