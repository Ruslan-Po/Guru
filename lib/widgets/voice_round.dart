import 'package:flutter/material.dart';
import 'package:guru/stiles/app_titles.dart';

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
          colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(15, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(voiceTitle, style: AppTextStyles.buttons),
    );
  }
}
