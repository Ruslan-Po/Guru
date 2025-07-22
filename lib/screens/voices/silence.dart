import 'package:flutter/material.dart';
import 'package:guru/fade_text_anim.dart';
import 'package:guru/stiles/app_titles.dart';
import 'package:guru/widgets/glow_wrapper.dart';
import 'package:guru/widgets/microphone.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:guru/services/openai_repository.dart';
import 'package:vibration/vibration.dart';

enum DisplayState { idle, listening, waitingAi, aiAnswer }

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
  String _aiAnswerText = "";
  DisplayState _displayState = DisplayState.idle;
  List<String> _lastAiAnswers = [];

  final OpenAIRepository _aiRepo = OpenAIRepository();
  final PhilosopherVoice _voice = PhilosopherVoice.silence;

  bool _isDisposed = false;

  void _vibrate() async {
    bool hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint("SilenceVoice: INIT");
    _speech = stt.SpeechToText();
    _initSpeech();

    _recognizedText = "Hold the button and speak";
    _aiAnswerText = "";
    _displayState = DisplayState.idle;
    _isRecording = false;
    _lastAiAnswers = [];
    _isDisposed = false;
  }

  @override
  void dispose() {
    debugPrint("SilenceVoice: DISPOSE");
    _isDisposed = true;
    _speech.stop();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) => debugPrint('Speech error: $error'),
    );
    if (mounted && !_isDisposed) setState(() {});
  }

  void _startListening() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) => debugPrint('Speech error: $error'),
    );
    if (!_speechAvailable || _isDisposed) return;
    await _speech.listen(
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 10),
      localeId: 'ru_RU',
      onResult: (result) async {
        debugPrint(
          "onResult: ${result.recognizedWords} (final: ${result.finalResult})",
        );
        if (mounted && !_isDisposed) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _displayState = DisplayState.listening;
          });
        }
        if (result.finalResult) {
          if (result.recognizedWords.trim().isNotEmpty) {
            if (mounted && !_isDisposed) {
              setState(() {
                _displayState = DisplayState.waitingAi;
              });
            }
            final aiAnswer = await _aiRepo.getPhilosopherAnswer(
              userPrompt: result.recognizedWords,
              voice: _voice,
              lastAiAnswers: _lastAiAnswers,
            );
            if (mounted && !_isDisposed) {
              setState(() {
                _aiAnswerText = aiAnswer;
                _displayState = DisplayState.aiAnswer;
                _lastAiAnswers.add(aiAnswer);
                if (_lastAiAnswers.length > 3) {
                  _lastAiAnswers.removeAt(0);
                }
              });
            }
          }
        }
      },
    );
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if ((status == 'done' || status == 'notListening') &&
        mounted &&
        !_isDisposed) {
      if (_recognizedText.trim().isEmpty) {
        setState(() {
          _recognizedText = "Nothing was recognized.";
          _displayState = DisplayState.idle;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isDisposed) {
            setState(() {
              _recognizedText = "Hold the button and speak";
              _displayState = DisplayState.idle;
            });
          }
        });
      } else {
        if (_displayState != DisplayState.aiAnswer &&
            _displayState != DisplayState.waitingAi) {
          setState(() {
            _displayState = DisplayState.idle;
          });
        }
      }
    }
  }

  void _stopListening() async {
    if (_isDisposed) return;
    await _speech.stop();
  }

  void _regenerateAiAnswer() async {
    if (_recognizedText.trim().isEmpty ||
        _recognizedText == "Nothing was recognized." ||
        _displayState == DisplayState.waitingAi) {
      return;
    }
    setState(() {
      _displayState = DisplayState.waitingAi;
    });

    final aiAnswer = await _aiRepo.getPhilosopherAnswer(
      userPrompt: _recognizedText,
      voice: _voice,
      lastAiAnswers: _lastAiAnswers,
    );
    if (mounted && !_isDisposed) {
      setState(() {
        _aiAnswerText = aiAnswer;
        _displayState = DisplayState.aiAnswer;
        _lastAiAnswers.add(aiAnswer);
        if (_lastAiAnswers.length > 3) {
          _lastAiAnswers.removeAt(0);
        }
      });
    }
  }

  // void _resetAll() {
  //   if (_isDisposed) return;
  //   setState(() {
  //     _recognizedText = "Hold the button and speak";
  //     _aiAnswerText = "";
  //     _displayState = DisplayState.idle;
  //     _isRecording = false;
  //     _lastAiAnswers = [];
  //   });
  //   _initSpeech();
  // }

  Widget _buildText() {
    String textToShow = "";
    TextStyle style = AppTextStyles.silenceAnswer;
    Duration fadeIn = const Duration(milliseconds: 1500);
    Duration fadeOut = const Duration(milliseconds: 400);

    if (_displayState == DisplayState.aiAnswer) {
      textToShow = _aiAnswerText;
    } else if (_displayState == DisplayState.listening) {
      textToShow = _recognizedText;
      fadeIn = Duration.zero;
      fadeOut = Duration.zero;
    } else if (_displayState == DisplayState.waitingAi) {
      textToShow = "Waiting for Guru’s answer...";
      style = AppTextStyles.silenceAnswer;
      fadeIn = Duration.zero;
      fadeOut = Duration.zero;
    } else {
      textToShow = _recognizedText;
      fadeIn = Duration.zero;
      fadeOut = Duration.zero;
    }

    return FadeSwitchingText(
      text: textToShow,
      style: style,
      fadeInDuration: fadeIn,
      fadeOutDuration: fadeOut,
    );
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
                  child: _buildText(),
                ),
              ),
            ),
            Positioned(
              bottom: bottomPadding,
              left: (screenSize.width - micSize) / 2.37,
              child: GestureDetector(
                onLongPressStart: (_) {
                  _vibrate();
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
                  glowColor: const Color(0xFFE2E7EF), // цвет тишины!
                  child: SizedBox(
                    width: micSize,
                    height: micSize,
                    child: const MicRound(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenSize.width * 0.1,
              bottom: bottomPadding + micSize / 1.1,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  _vibrate();
                },
                icon: Image.asset(
                  'assets/icons/prev.png',
                  width: screenSize.width * 0.08,
                  height: screenSize.width * 0.08,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: screenSize.width * 0.77,
              bottom: bottomPadding + micSize / 1.1,
              child: IconButton(
                onPressed: () {
                  _vibrate();
                  _regenerateAiAnswer();
                },
                icon: Image.asset(
                  'assets/icons/refresh.png',
                  width: screenSize.width * 0.08,
                  height: screenSize.width * 0.08,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
