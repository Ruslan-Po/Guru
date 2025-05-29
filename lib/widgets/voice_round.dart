import 'package:flutter/material.dart';

class VoiceRound extends StatelessWidget {
  final String voiceTitle;

  const VoiceRound({super.key, required this.voiceTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [const Color(0xFF4D574E), const Color(0xFF956E2F)],
        ),
        color: const Color.fromARGB(255, 0, 158, 13),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(15, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(voiceTitle),
    );
  }
}
