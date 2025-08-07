import 'package:flutter/material.dart';
import 'package:guru/stiles/app_titles.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingOverlay({super.key, required this.onFinish});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _instructions = [
    "1. Formulate your question or problem",
    "2. Choose the Guru's voice",
    "3. Speak your request and receive an answer",
  ];

  void _next() {
    if (_currentPage < _instructions.length - 1) {
      setState(() => _currentPage++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
            ),
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(74),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 120,
                child: PageView.builder(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _instructions.length,
                  itemBuilder: (_, i) => Center(
                    child: Text(
                      _instructions[i],
                      style: AppTextStyles.descriptions,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4D574E), // Цвет кнопки (фон)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                ),
                onPressed: _next,
                child: Text(
                  style: AppTextStyles.buttons,
                  _currentPage < _instructions.length - 1 ? "Next" : "Proceed",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
