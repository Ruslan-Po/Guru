import 'package:flutter/material.dart';
import 'package:guru/widgets/glow_wrapper.dart';
import 'package:guru/widgets/microphone.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LogicVoice extends StatefulWidget {
  const LogicVoice({super.key});

  @override
  State<LogicVoice> createState() => _LogicState();
}

class _LogicState extends State<LogicVoice> {
  bool _isRecording = false;
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  String _recognizedText = "Нажмите и удерживайте микрофон";
  String _lastRecognized = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) => debugPrint('Speech error: $error'),
    );
    setState(() {});
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _recognizedText = _lastRecognized.isNotEmpty
            ? _lastRecognized
            : "Ничего не распознано";
      });
    }
  }

  void _startListening() async {
    if (!_speechAvailable) return;
    await _speech.listen(
      localeId: 'ru_RU',
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 5),
      onResult: (result) {
        _lastRecognized = result.recognizedWords;
        setState(() {
          _recognizedText = _lastRecognized;
        });
      },
    );
  }

  void _stopListening() async {
    await _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double bottomPadding = screenSize.height * 0.03;
    final double micSize = screenSize.width * 0.25;
    final double textMaxWidth = screenSize.width * 0.84;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: textMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.07,
                  ),
                  child: Text(
                    _recognizedText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
            // Микрофон по центру снизу
            Positioned(
              bottom: bottomPadding,
              left: (screenSize.width - micSize) / 2.3,
              child: GestureDetector(
                onLongPressStart: (_) {
                  setState(() {
                    _isRecording = true;
                  });
                  _startListening();
                },
                onLongPressEnd: (_) {
                  setState(() {
                    _isRecording = false;
                  });
                  _stopListening();
                },
                child: GlowingMicPainterWrapper(
                  glowing: _isRecording,
                  child: SizedBox(
                    width: micSize,
                    height: micSize,
                    child: const MicRound(),
                  ),
                ),
              ),
            ),
            // Кнопка назад — снизу слева
            Positioned(
              left: screenSize.width * 0.04,
              bottom: bottomPadding + micSize / 3,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                iconSize: screenSize.width * 0.085,
              ),
            ),
            Positioned(
              left: screenSize.width * 0.8,
              bottom: bottomPadding + micSize / 3.3,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                iconSize: screenSize.width * 0.11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
