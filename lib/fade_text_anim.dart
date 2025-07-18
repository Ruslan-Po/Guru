import 'package:flutter/material.dart';

class FadeSwitchingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration fadeOutDuration;
  final Duration fadeInDuration;

  const FadeSwitchingText({
    super.key,
    required this.text,
    this.style,
    this.fadeOutDuration = const Duration(milliseconds: 400),
    this.fadeInDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<FadeSwitchingText> createState() => _FadeSwitchingTextState();
}

class _FadeSwitchingTextState extends State<FadeSwitchingText>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _currentText = '';
  String _prevText = '';
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    debugPrint('FadeSwitchingText initState $_currentText');
    _currentText = widget.text;
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.value = 1; // сразу показываем текст
  }

  @override
  void didUpdateWidget(FadeSwitchingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _currentText) {
      _switchText(widget.text);
    }
  }

  void _switchText(String newText) async {
    // Начинаем fade out
    setState(() {
      _isFadingOut = true;
      _prevText = _currentText;
    });
    _fadeController.duration = widget.fadeOutDuration;
    await _fadeController.reverse(from: 1); // 1→0

    // Меняем текст
    setState(() {
      _currentText = newText;
      _isFadingOut = false;
    });

    // Делаем fade in
    _fadeController.duration = widget.fadeInDuration;
    await _fadeController.forward(from: 0); // 0→1
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        _isFadingOut ? _prevText : _currentText,
        style: widget.style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
