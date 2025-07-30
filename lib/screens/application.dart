import 'package:flutter/material.dart';
import 'package:guru/app_routes.dart';
import 'package:guru/screens/home.dart';
import 'package:guru/screens/subscription.dart';
import 'package:guru/screens/voices/flow.dart';
import 'package:guru/screens/voices/logic.dart';
import 'package:guru/screens/voices/poetry.dart';
import 'package:guru/screens/voices/silence.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.subscription,
      routes: {
        Routes.home: (context) => Home(),
        Routes.silence: (context) => SilenceVoice(),
        Routes.flow: (context) => FlowVoice(),
        Routes.poetry: (context) => PoetryVoice(),
        Routes.logic: (context) => LogicVoice(),
        Routes.subscription: (context) => Subscription(),
      },
    );
  }
}
