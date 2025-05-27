import 'package:flutter/material.dart';

class MainRound extends StatefulWidget {
  final double size;
  final Widget child;

  const MainRound({super.key, required this.size, required this.child});

  @override
  State<MainRound> createState() => _MainRoundState();
}

class _MainRoundState extends State<MainRound> {
  late Widget _currentChild;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
  }

  void updateChild(Widget newChild) {
    setState(() {
      _currentChild = newChild;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: widget.size,
        height: widget.size,
        color: const Color.fromARGB(255, 231, 239, 246),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _currentChild,
            // сюда можно добавить еще что угодно, например overlay-кнопки
          ],
        ),
      ),
    );
  }
}
