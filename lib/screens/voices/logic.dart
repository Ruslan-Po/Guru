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
    return Center(
      child: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
            ),
          ),
          child: Stack(
            children: [
              // Текст по центру экрана
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _recognizedText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
              // Нижняя панель с кнопками
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 90),
                        GestureDetector(
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
                            child: const MicRound(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
