import 'package:flutter/material.dart';
import 'package:glossy/glossy.dart';
import 'package:guru/widgets/subscription_widget.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  int _activeIndex = 1;
  static const double _normalHeight = 150;
  static const double _normalWidth = 120;
  static const double _activeHeight = 180;
  static const double _activeWidth = 150;
  static const Duration _duration = Duration(milliseconds: 250);

  final List<String> titles = ["Weekly", "Monthly", "Quarterly"];
  final List<String> prices = ['0.99\$', '2.99\$', '4.99\$'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.abc_rounded),
                Text(
                  'Subscription Name',
                  style: TextStyle(color: Colors.amber),
                ),
                SizedBox(
                  height: _activeHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(3, (i) {
                      final bool isActive = _activeIndex == i;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _activeIndex = i);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(44),
                            border: Border.all(
                              color: isActive
                                  ? Colors.amber
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 13,
                                      spreadRadius: 6,
                                    ),
                                  ]
                                : [],
                          ),
                          child: SubscriptionWidget(
                            subscriptionName: titles[i],
                            subscriptionCost: prices[i],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
