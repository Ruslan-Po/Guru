import 'package:flutter/material.dart';

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
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
        ),
        borderRadius: BorderRadius.circular(40),
        // border и boxShadow УБРАНЫ!
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              subscriptionName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              subscriptionCost,
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
