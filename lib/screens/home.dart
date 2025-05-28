import 'package:flutter/material.dart';
import 'package:guru/widgets/main_round.dart';
import 'package:guru/widgets/voice_round.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _activeIndex = -1;

  static const double _normalSize = 70;
  static const double _activeSize = 100;
  static const Duration _duration = Duration(milliseconds: 250);

  double get _scaleNormal => 1.0;
  double get _scaleActive => _activeSize / _normalSize;

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
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeIndex = 0;
                        });
                      },
                      child: AnimatedScale(
                        scale: _activeIndex == 0 ? _scaleActive : _scaleNormal,
                        duration: _duration,
                        curve: Curves.easeOut,
                        child: SizedBox(
                          width: _normalSize,
                          height: _normalSize,
                          child: VoiceRound(voiceTitle: "Flow"),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 710,
                    left: 120,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeIndex = 1;
                        });
                      },
                      child: AnimatedScale(
                        scale: _activeIndex == 1 ? _scaleActive : _scaleNormal,
                        duration: _duration,
                        curve: Curves.easeOut,
                        child: SizedBox(
                          width: _normalSize,
                          height: _normalSize,
                          child: VoiceRound(voiceTitle: "Poem"),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 710,
                    right: 120,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeIndex = 2;
                        });
                      },
                      child: AnimatedScale(
                        scale: _activeIndex == 2 ? _scaleActive : _scaleNormal,
                        duration: _duration,
                        curve: Curves.easeOut,
                        child: SizedBox(
                          width: _normalSize,
                          height: _normalSize,
                          child: VoiceRound(voiceTitle: "Silence"),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 680,
                    right: 30,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeIndex = 3;
                        });
                      },
                      child: AnimatedScale(
                        scale: _activeIndex == 3 ? _scaleActive : _scaleNormal,
                        duration: _duration,
                        curve: Curves.easeOut,
                        child: SizedBox(
                          width: _normalSize,
                          height: _normalSize,
                          child: VoiceRound(voiceTitle: "Logic"),
                        ),
                      ),
                    ),
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
