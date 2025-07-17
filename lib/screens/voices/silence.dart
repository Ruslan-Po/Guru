import 'package:flutter/material.dart';
import 'package:guru/fade_text_anim.dart';
import 'package:guru/widgets/glow_wrapper.dart';
import 'package:guru/widgets/microphone.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:guru/services/openai_repository.dart';

class SilenceVoice extends StatefulWidget {
  const SilenceVoice({super.key});

  @override
  State<SilenceVoice> createState() => _SilenceVoiceState();
}

class _SilenceVoiceState extends State<SilenceVoice> {
  bool _isRecording = false;
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  String _recognizedText = "Hold the button and speak";
  String _lastRecognized = "";
  final List<String> _lastAiAnswers = [];

  final OpenAIRepository _aiRepo = OpenAIRepository();
  final PhilosopherVoice _voice = PhilosopherVoice.silence;

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

  void _testAI() async {
    setState(() => _recognizedText = "Waiting for test answer...");
    final aiAnswer = await _aiRepo.getPhilosopherAnswer(
      userPrompt: "смерть пугает меня",
      voice: _voice,
      lastAiAnswers: _lastAiAnswers, // <-- добавлено
    );
    setState(() {
      _recognizedText = aiAnswer;
      _lastAiAnswers.add(aiAnswer);
      if (_lastAiAnswers.length > 3) {
        _lastAiAnswers.removeAt(0);
      }
    });
    debugPrint(_lastAiAnswers.join('\n'));
  }

  void _onSpeechStatus(String status) async {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      String text = _lastRecognized.isNotEmpty
          ? _lastRecognized
          : "Nothing was recognized.";
      setState(() {
        _recognizedText = text;
      });

      if (text.trim().isNotEmpty && text != "Nothing was recognized.") {
        setState(
          () => _recognizedText = "Waiting for the philosopher's answer...",
        );
        final aiAnswer = await _aiRepo.getPhilosopherAnswer(
          userPrompt: text,
          voice: _voice,
          lastAiAnswers: _lastAiAnswers, // <-- добавлено
        );
        setState(() {
          _recognizedText = aiAnswer;
          _lastAiAnswers.add(aiAnswer);
          if (_lastAiAnswers.length > 3) {
            _lastAiAnswers.removeAt(0);
          }
        });
      }
    }
  }

  void _startListening() async {
    if (!_speechAvailable) return;
    await _speech.listen(
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
                  child: FadeSwitchingText(
                    text: _recognizedText,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
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
                onPressed: () {}, // Можно добавить обновление ответа по желанию
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                iconSize: screenSize.width * 0.11,
              ),
            ),
            Positioned(
              top: 80,
              right: 30,
              child: ElevatedButton(
                onPressed: _testAI,
                child: const Text("Test AI"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
