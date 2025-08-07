import 'package:flutter/material.dart';
import 'package:guru/app_routes.dart';
import 'package:guru/screens/home.dart';
import 'package:guru/screens/subscription.dart';
import 'package:guru/screens/voices/flow.dart';
import 'package:guru/screens/voices/logic.dart';
import 'package:guru/screens/voices/poetry.dart';
import 'package:guru/screens/voices/silence.dart';
import 'package:guru/services/premium_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => const Home(),
        Routes.silence: (context) => PremiumGate(child: SilenceVoice()),
        Routes.flow: (context) => PremiumGate(child: FlowVoice()),
        Routes.poetry: (context) => PremiumGate(child: PoetryVoice()),
        Routes.logic: (context) => PremiumGate(child: LogicVoice()),
        Routes.subscription: (context) => const Subscription(),
      },
    );
  }
}
