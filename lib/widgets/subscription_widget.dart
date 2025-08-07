import 'package:flutter/material.dart';
import 'package:guru/stiles/app_titles.dart';

class SubscriptionWidget extends StatelessWidget {
  final String subscriptionName;
  final String subscriptionCost;

  const SubscriptionWidget({
    super.key,
    required this.subscriptionName,
    required this.subscriptionCost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 130,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subscriptionName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subscriptionCost.isNotEmpty ? subscriptionCost : '...',
              style: AppTextStyles.cost,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
