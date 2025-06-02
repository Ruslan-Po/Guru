import 'package:flutter/material.dart';

class SilenceVoice extends StatefulWidget {
  const SilenceVoice({super.key});

  @override
  State<SilenceVoice> createState() => _SilenceState();
}

class _SilenceState extends State<SilenceVoice> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF4D574E), Color(0xFFB68B4B)],
            ),
          ),
          child: Placeholder(),
        ),
      ),
    );
  }
}
