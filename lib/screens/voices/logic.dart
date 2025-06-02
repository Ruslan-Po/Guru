import 'package:flutter/material.dart';

class LogicVoice extends StatefulWidget {
  const LogicVoice({super.key});

  @override
  State<LogicVoice> createState() => _LogicState();
}

class _LogicState extends State<LogicVoice> {
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
