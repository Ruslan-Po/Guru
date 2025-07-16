import 'dart:math';
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

  final List<String> titles = ["Flow", "Poetry", "Silence", "Logic"];

  final List<double> angles = [50, 75, 100, 125];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final double mainRoundRadius = 175;
    final double voiceButtonRadius = mainRoundRadius + 36;

    final double centerX = screenSize.width / 2;
    final double centerY = screenSize.height * 0.60;

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
            child: Stack(
              children: [
                
                Positioned(
                  top: -40,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: screenSize.height * 0.7,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
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

                Positioned(
                  left: centerX - mainRoundRadius,
                  top: centerY - mainRoundRadius,
                  child: MainRound(
                    size: mainRoundRadius * 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        descriptions[_activeIndex],
                        style: AppTextStyles.descriptions,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                ...List.generate(4, (i) {
                  final double angleRad = angles[i] * pi / 180;
                  final double x =
                      centerX +
                      voiceButtonRadius * cos(angleRad) -
                      _normalSize / 2;
                  final double y =
                      centerY +
                      voiceButtonRadius * sin(angleRad) -
                      _normalSize / 2;

                  return Positioned(
                    left: x,
                    top: y,
                    child: GestureDetector(
                      onTap: () => setState(() => _activeIndex = i),
                      onDoubleTap: () =>
                          _navigationByIndex(context, _activeIndex),
                      child: AnimatedScale(
                        scale: _activeIndex == i
                            ? _activeSize / _normalSize
                            : 1.0,
                        duration: _duration,
                        curve: Curves.easeOut,
                        child: SizedBox(
                          width: _normalSize,
                          height: _normalSize,
                          child: VoiceRound(voiceTitle: titles[i]),
                        ),
                      ),
                    ),
                  );
                }),
                // Кнопка Confirm внизу — адаптивно к низу экрана, справа
                Positioned(
                  right: screenSize.width * 0.08,
                  bottom: screenSize.height * 0.04,
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
    );
  }
}
