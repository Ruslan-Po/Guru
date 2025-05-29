import 'package:flutter/material.dart';
import 'package:guru/widgets/main_round.dart';
import 'package:guru/widgets/voice_round.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _activeIndex = 1;

  static const double _normalSize = 70;
  static const double _activeSize = 100;
  static const Duration _duration = Duration(milliseconds: 250);

  double get _scaleNormal => 1.0;
  double get _scaleActive => _activeSize / _normalSize;

  final List<String> images = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [const Color(0xFF4D574E), const Color(0xFFB68B4B)],
              ),
            ),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 150,
                        right: 5,
                        left: 5,
                      ),
                      child: MainRound(size: 350, child: Text('MAIN')),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 250,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Image.asset(
                          images[_activeIndex],
                          key: ValueKey<int>(_activeIndex),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 665,
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
                    top: 665,
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
