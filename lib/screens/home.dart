import 'package:flutter/material.dart';
import 'package:guru/widgets/main_round.dart';
import 'package:guru/widgets/voice_round.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox.expand(
          child: Container(
            color: Colors.black,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 350),
                    child: MainRound(size: 400, child: Text('MAIN')),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Image.asset('assets/images/budha.png'),
                  ),
                  Positioned(
                    top: 680,
                    left: 30,
                    child: VoiceRound(voiceTitle: "Flow"),
                  ),
                  Positioned(
                    top: 710,
                    left: 120,
                    child: VoiceRound(voiceTitle: "Poem"),
                  ),
                  Positioned(
                    top: 710,
                    right: 120,
                    child: VoiceRound(voiceTitle: "Silence"),
                  ),
                  Positioned(
                    top: 680,
                    right: 30,
                    child: VoiceRound(voiceTitle: "Logic"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
