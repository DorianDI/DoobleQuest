import 'package:flutter/material.dart';

class ExtincteurForceGamePage extends StatefulWidget {
  const ExtincteurForceGamePage({super.key});

  @override
  State<ExtincteurForceGamePage> createState() => _ExtincteurForceGamePageState();
}

class _ExtincteurForceGamePageState extends State<ExtincteurForceGamePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF63CCE9)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),
          Text('MODE FORCE'),
        ],
      ),
    );
  }
}
