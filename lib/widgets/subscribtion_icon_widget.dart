import 'package:flutter/material.dart';

class SubscribtionIconWidget extends StatelessWidget {
  const SubscribtionIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(5, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/icons/follow.png',
        scale: 20,
        color: Color.fromARGB(189, 163, 239, 224),
      ),
    );
  }
}
