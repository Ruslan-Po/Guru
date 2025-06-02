import 'package:flutter/material.dart';

class FlowVoice extends StatefulWidget {
  const FlowVoice({super.key});

  @override
  State<FlowVoice> createState() => _FlowVoiceState();
}

class _FlowVoiceState extends State<FlowVoice> {
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
