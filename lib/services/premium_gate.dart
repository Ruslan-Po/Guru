import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guru/screens/subscription.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;

  const PremiumGate({super.key, required this.child});

  Future<bool> _isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isPremium(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == true) {
          return child;
        } else {
          return const Subscription();
        }
      },
    );
  }
}
