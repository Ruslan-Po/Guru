import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:guru/stiles/app_titles.dart';
import 'package:guru/widgets/subscription_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  List<ProductDetails> _products = [];
  bool _iapAvailable = false;
  int _activeIndex = 0;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isPremium = false;

  final List<String> productOrder = [
    'guru_weekly',
    'guru_monthly',
    'guru_quarterly',
  ];

  final Map<String, String> productTitles = {
    'guru_weekly': 'Weekly',
    'guru_monthly': 'Monthly',
    'guru_quarterly': 'Quarterly',
  };

  final Map<String, String> productImages = {
    'guru_weekly': 'assets/subscroption_icons/weekly.png',
    'guru_monthly': 'assets/subscroption_icons/monthly.png',
    'guru_quarterly': 'assets/subscroption_icons/quarterly.png',
  };

  final Map<String, String> productDescriptions = {
    'guru_weekly': 'Weekly access to Guru voice',
    'guru_monthly': 'Monthly access to Guru voice',
    'guru_quarterly': 'Quarterly access to Guru voice',
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadPremiumStatus();
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase Stream error: $error'),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPremium = prefs.getBool('isPremium') ?? false;
    });
  }

  Future<void> _savePremiumStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    setState(() {
      _isPremium = value;
    });
  }

  Future<void> _loadProducts() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    setState(() => _iapAvailable = available);

    if (!available) return;

    const Set<String> kProductIds = {
      'guru_weekly',
      'guru_monthly',
      'guru_quarterly',
    };
    final response = await InAppPurchase.instance.queryProductDetails(
      kProductIds,
    );

    if (response.error != null) return;

    setState(() {
      _products = response.productDetails;
    });
  }

  void _buy(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    bool hasPremium = false;
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        hasPremium = true;
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
    await _savePremiumStatus(hasPremium);
  }

  // Сортируем продукты в нужном порядке, без null и ошибок типов
  List<ProductDetails> get orderedProducts {
    final List<ProductDetails> result = [];
    for (final id in productOrder) {
      final found = _products.where((p) => p.id == id);
      if (found.isNotEmpty) {
        result.add(found.first);
      }
    }
    return result;
  }

  // Восстановление покупок (restore purchases)
  Future<void> _restorePremiumStatus() async {
    await InAppPurchase.instance.restorePurchases();
    // _handlePurchaseUpdates вызовется автоматически
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://ruslan-po.github.io/guru-privacy-policy');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchTermsofUse() async {
    final url = Uri.parse(
      'https://ruslan-po.github.io/guru-privacy-policy/terms.html',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonMaxWidth = screenWidth * 0.6;
    final productsToShow = orderedProducts;

    // Без продуктов — прелоадер
    if (productsToShow.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Чтобы активный индекс не вышел за границы
    int fixedActiveIndex = _activeIndex.clamp(0, productsToShow.length - 1);

    final activeProduct = productsToShow[fixedActiveIndex];

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
            const SizedBox(height: 20),
            if (_isPremium)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Premium is active!',
                  style: TextStyle(
                    color: Color.fromARGB(177, 255, 193, 7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Image.asset(
                      productImages[activeProduct.id] ?? '',
                      scale: 4,
                      key: ValueKey<String>(activeProduct.id),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                productDescriptions[activeProduct.id] ?? '',
                style: AppTextStyles.subscripeDescriptionText,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '3-day free trial for new users',
              style: AppTextStyles.disclaimer,
            ),
            Text(
              '* The final price may differ and will be displayed on the payment sheet due to '
              'local taxes or currency conversion.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color.fromARGB(228, 163, 239, 224)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _launchPrivacyPolicy();
                    debugPrint('Tap');
                  },
                  child: Text(
                    'Private Policy',
                    style: AppTextStyles.disclaimer.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    _launchTermsofUse();
                    debugPrint('Tap');
                  },
                  child: Text(
                    'Terms Of Use',
                    style: AppTextStyles.disclaimer.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(productsToShow.length, (i) {
                  final product = productsToShow[i];
                  final isActive = fixedActiveIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _activeIndex = i);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 8.0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(2),
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
                                      color: Colors.amber.withAlpha(100),
                                      blurRadius: 13,
                                      spreadRadius: 6,
                                    ),
                                  ]
                                : [],
                          ),
                          child: SubscriptionWidget(
                            subscriptionName: productTitles[product.id] ?? '',
                            subscriptionCost: product.price,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    'assets/icons/prev.png',
                    scale: 15,
                    color: const Color.fromARGB(149, 255, 255, 255),
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: buttonMaxWidth),
                  child: GestureDetector(
                    onTap: () {
                      final product = productsToShow[fixedActiveIndex];
                      _buy(product);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 400 ? 15 : 40,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(167, 247, 226, 251),
                            Color.fromARGB(255, 213, 193, 133),
                            Color.fromARGB(115, 226, 231, 239),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: const Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Get a subscription',
                            style: TextStyle(
                              color: Color.fromARGB(255, 9, 0, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    'assets/icons/forw.png',
                    scale: 15,
                    color: const Color.fromARGB(149, 255, 255, 255),
                  ),
                ),
              ],
            ),

            // TextButton(
            //   onPressed: _restorePremiumStatus,
            //   child: const Text('Restore purchases'),
            // ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
