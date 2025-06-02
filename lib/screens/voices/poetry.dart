import 'package:flutter/material.dart';

class PoetryVoice extends StatefulWidget {
  const PoetryVoice({super.key});

  @override
  State<PoetryVoice> createState() => _PoetryState();
}

class _PoetryState extends State<PoetryVoice> {
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
