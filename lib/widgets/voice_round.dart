import 'package:flutter/material.dart';

class VoiceRound extends StatelessWidget {
  final String voiceTitle;

  const VoiceRound({super.key, required this.voiceTitle});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          children: [
            Container(color: Colors.amber),
            Center(child: Text(voiceTitle)),
          ],
        ),
      ),
    );
  }
}
