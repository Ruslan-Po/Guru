import 'package:flutter/material.dart';
import 'package:guru/app_routes.dart';
import 'package:guru/stiles/app_titles.dart';
import 'package:guru/voice_descriptions.dart';
import 'package:guru/widgets/main_round.dart';
import 'package:guru/widgets/voice_round.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

void _navigationByIndex(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushNamed(context, Routes.flow);
      break;
    case 1:
      Navigator.pushNamed(context, Routes.poetry);
      break;
    case 2:
      Navigator.pushNamed(context, Routes.silence);
      break;
    case 3:
      Navigator.pushNamed(context, Routes.logic);
      break;
  }
}

class _HomeState extends State<Home> {
  int _activeIndex = 1;

  static const double _normalSize = 70;
  static const double _activeSize = 100;
  static const Duration _duration = Duration(milliseconds: 250);

  double get _scaleNormal => 1.0;
  double get _scaleActive => _activeSize / _normalSize;

  final List<String> images = [
    'assets/images/flow.png',
    'assets/images/poetry.png',
    'assets/images/silence.png',
    'assets/images/logic.png',
  ];

  final List<String> descriptions = [
    VoiceDescriptions.flow,
    VoiceDescriptions.poetry,
    VoiceDescriptions.silence,
    VoiceDescriptions.logic,
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
                colors: [
                  const Color.fromARGB(255, 0, 0, 0),
                  const Color(0xFF4D574E),
                ],
              ),
            ),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 600,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Image.asset(
                          images[_activeIndex],
                          key: ValueKey<int>(_activeIndex),
                          scale: 0.4,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 150,
                        right: 5,
                        left: 5,
                      ),
                      child: MainRound(
                        size: 350,
                        child: Text(
                          descriptions[_activeIndex],
                          style: AppTextStyles.descriptions,
                          textAlign: TextAlign.center,
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
                      onDoubleTap: () =>
                          _navigationByIndex(context, _activeIndex),
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
                      onDoubleTap: () =>
                          _navigationByIndex(context, _activeIndex),
                      child: AnimatedScale(
                        scale: _activeIndex == 1 ? _scaleActive : _scaleNormal,
                        duration: _duration,
                        curve: Curves.easeOut,
                        child: SizedBox(
                          width: _normalSize,
                          height: _normalSize,
                          child: VoiceRound(voiceTitle: "Poetry"),
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
                      onDoubleTap: () =>
                          _navigationByIndex(context, _activeIndex),
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
                      onDoubleTap: () =>
                          _navigationByIndex(context, _activeIndex),
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
                  Positioned(
                    top: 800,
                    right: 30,
                    child: GestureDetector(
                      onTap: () {
                        _navigationByIndex(context, _activeIndex);
                      },
                      child: VoiceRound(voiceTitle: "Confirm"),
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
