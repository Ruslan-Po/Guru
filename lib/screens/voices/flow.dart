import 'package:flutter/material.dart';
import 'package:guru/widgets/glow_wrapper.dart';
import 'package:guru/widgets/microphone.dart';

class FlowVoice extends StatefulWidget {
  const FlowVoice({super.key});

  @override
  State<FlowVoice> createState() => _FlowVoiceState();
}

class _FlowVoiceState extends State<FlowVoice> {
  bool _isRecording = false;
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
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('silence'),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back),
                        ),
                        SizedBox(width: 90),
                        GestureDetector(
                          onLongPressStart: (_) {
                            setState(() {
                              _isRecording = true;
                            });
                            debugPrint('end');
                          },
                          onLongPressEnd: (_) {
                            setState(() {
                              _isRecording = false;
                            });
                            debugPrint('end');
                          },
                          child: GlowingMicPainterWrapper(
                            glowing: _isRecording,
                            child: const MicRound(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
