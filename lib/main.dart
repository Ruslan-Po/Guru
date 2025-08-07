import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guru/screens/application.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: "env.txt", isOptional: false);
  runApp(const App());
}
