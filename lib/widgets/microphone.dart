import 'package:flutter/material.dart';

class MicRound extends StatelessWidget {
  final bool bIsActive = false;

  const MicRound({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
        ),
      ),
      child: Image.asset(
        'assets/images/mic.png',
        color: Colors.grey,
        width: 90,
        height: 90,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }
}
