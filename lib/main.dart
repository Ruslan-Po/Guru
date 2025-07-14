import 'package:flutter/material.dart';
import 'package:guru/screens/application.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'dart:io'; // импорт наверху файла

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env.txt", isOptional: false);
  runApp(const App());
}
