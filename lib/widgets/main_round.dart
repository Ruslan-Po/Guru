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
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [const Color(0xFF4D574E), const Color(0xFF956E2F)],
        ),
        color: const Color.fromARGB(255, 0, 158, 13),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 8,
            offset: Offset(15, 15),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: _currentChild,
    );
  }
}
