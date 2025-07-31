import 'package:flutter/material.dart';
import 'package:guru/stiles/app_titles.dart';
import 'package:guru/widgets/subscription_widget.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  int _activeIndex = 1;

  // static const double _normalHeight = 150;
  // static const double _normalWidth = 120;
  // static const double _activeHeight = 180;
  // static const double _activeWidth = 150;
  // static const Duration _duration = Duration(milliseconds: 250);

  final List<String> titles = ["Weekly", "Monthly", "Quarterly"];

  final List<String> prices = ['0.99\$', '2.99\$', '4.99\$'];

  String _showDescription(int index) {
    String description = '';
    switch (index) {
      case 0:
        description = 'Weekly access to Guru voice ';
        break;
      case 1:
        description = 'Monthly access to Guru voice';
        break;
      case 2:
        description = 'Quarterly access to Guru voice';
        break;
    }
    return description;
  }

  String _getImage(int index) {
    String path = '';
    switch (index) {
      case 0:
        path = 'assets/subscroption_icons/weekly.png';
        break;
      case 1:
        path = 'assets/subscroption_icons/monthly.png';
        break;
      case 2:
        path = 'assets/subscroption_icons/quarterly.png';
        break;
    }
    return path;
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Image.asset(
                      _getImage(_activeIndex),
                      scale: 4,
                      key: ValueKey<int>(_activeIndex),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _showDescription(_activeIndex),
                style: AppTextStyles.subscripeDescriptionText,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '3-day free trial for new users',
              style: AppTextStyles.disclaimer,
            ),
            SizedBox(
              height: 150,
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
                              ? const Color.fromARGB(255, 213, 193, 133)
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  debugPrint('tap');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(167, 247, 226, 251),
                        const Color.fromARGB(255, 213, 193, 133),
                        const Color.fromARGB(115, 226, 231, 239),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Get a subscription',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 9, 0, 0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
