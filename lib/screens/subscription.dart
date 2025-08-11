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
  final InAppPurchase _iap = InAppPurchase.instance;

  List<ProductDetails> _products = [];
  bool _iapAvailable = false;
  int _activeIndex = 0;
  bool _isPremium = false;
  bool _isProcessing = false;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  // Порядок показа продуктов
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

  // --- Анти‑спам для SnackBar ---
  DateTime _lastSnackAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastSnackMsg;

  // --- Анти‑дубликаты обработок покупок (некоторые стора присылают одно и то же несколько раз) ---
  final Set<String> _handledPurchaseIds = {};

  @override
  void initState() {
    super.initState();
    _initIAP();
    _loadPremiumStatus();
    _purchaseSub = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) {
        debugPrint('Purchase stream error: $e');
        _setProcessing(false);
        _showSnack('Purchase error. Please try again.');
      },
    );
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (mounted) setState(() => _iapAvailable = available);
    if (!available) return;

    const ids = {'guru_weekly', 'guru_monthly', 'guru_quarterly'};
    final response = await _iap.queryProductDetails(ids);

    if (response.error != null) {
      debugPrint('IAP query error: ${response.error}');
      return;
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Not found product IDs: ${response.notFoundIDs}');
    }

    // Сортируем по заданному порядку + добавляем неожиданные хвостом
    final map = {for (var p in response.productDetails) p.id: p};
    final ordered = <ProductDetails>[
      for (final id in productOrder)
        if (map[id] != null) map[id]!,
    ];
    for (final p in response.productDetails) {
      if (!ordered.any((e) => e.id == p.id)) ordered.add(p);
    }

    if (mounted) setState(() => _products = ordered);
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _isPremium = prefs.getBool('isPremium') ?? false);
    }
  }

  Future<void> _savePremiumStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    if (mounted) setState(() => _isPremium = value);
  }

  void _setProcessing(bool v) {
    if (mounted) setState(() => _isProcessing = v);
  }

  void _buy(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    _setProcessing(true);
    _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> _restorePurchases() async {
    _showSnack('Restoring purchases...');
    _setProcessing(true);
    await _iap.restorePurchases();
    // Результаты придут в _handlePurchaseUpdates
  }

  // Получаем "стабильный" идентификатор покупки, чтобы отсекать дубли
  String? _stablePurchaseId(PurchaseDetails p) {
    return p.purchaseID?.isNotEmpty == true
        ? p.purchaseID
        : p.verificationData.serverVerificationData.isNotEmpty
        ? p.verificationData.serverVerificationData
        : null;
  }

  bool _wasHandled(PurchaseDetails p) {
    final id = _stablePurchaseId(p);
    if (id == null) return false; // не можем отфильтровать — обработаем
    if (_handledPurchaseIds.contains(id)) return true;
    _handledPurchaseIds.add(id);
    return false;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    var hasPremium = _isPremium;

    bool anyRestored = false;
    bool anyPurchased = false;
    bool anyCanceled = false;
    String? firstError;

    for (final purchase in purchases) {
      // фильтр от повторной обработки
      if (_wasHandled(purchase)) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setProcessing(true);
          break;

        case PurchaseStatus.error:
          _setProcessing(false);
          firstError ??= purchase.error?.message ?? 'Unknown error';
          break;

        case PurchaseStatus.canceled:
          _setProcessing(false);
          anyCanceled = true;
          break;

        case PurchaseStatus.purchased:
          anyPurchased = true;
          hasPremium = true;
          if (purchase.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchase);
            } catch (e) {
              debugPrint('completePurchase error: $e');
            }
          }
          break;

        case PurchaseStatus.restored:
          anyRestored = true;
          hasPremium = true;
          if (purchase.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchase);
            } catch (e) {
              debugPrint('completePurchase error: $e');
            }
          }
          break;
      }
    }

    await _savePremiumStatus(hasPremium);
    _setProcessing(false);

    // Ровно один SnackBar по приоритету
    if (firstError != null) {
      _showSnack('Purchase failed: $firstError');
    } else if (anyCanceled) {
      _showSnack('Purchase cancelled.');
    } else if (anyRestored) {
      _showSnack(
        hasPremium ? 'Purchases restored.' : 'No purchases to restore.',
      );
    } else if (anyPurchased) {
      _showSnack('Thanks! Premium is active.');
    }
  }

  List<ProductDetails> get orderedProducts => _products;

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

  void _showSnack(String msg, {Duration dedupe = const Duration(seconds: 2)}) {
    if (!mounted) return;

    final now = DateTime.now();
    if (_lastSnackMsg == msg && now.difference(_lastSnackAt) < dedupe) {
      return; // не спамим одинаковыми сообщениями подряд
    }

    _lastSnackMsg = msg;
    _lastSnackAt = now;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonMaxWidth = screenWidth * 0.6;
    final productsToShow = orderedProducts;

    if (!_iapAvailable) {
      return const Scaffold(
        body: Center(child: Text('In-App Purchases are not available')),
      );
    }

    if (productsToShow.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final fixedActiveIndex = _activeIndex.clamp(0, productsToShow.length - 1);
    final activeProduct = productsToShow[fixedActiveIndex];

    return Scaffold(
      body: AbsorbPointer(
        absorbing: _isProcessing,
        child: Stack(
          children: [
            Container(
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
                            productImages[activeProduct.id] ??
                                'assets/transparent.png',
                            scale: 5,
                            key: ValueKey<String>(activeProduct.id),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '* The final price may differ and will be displayed on the payment sheet due to local taxes or currency conversion.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(228, 163, 239, 224),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _launchPrivacyPolicy,
                        child: Text(
                          'Privacy Policy',
                          style: AppTextStyles.disclaimer.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: _launchTermsofUse,
                        child: Text(
                          'Terms of Use',
                          style: AppTextStyles.disclaimer.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _restorePurchases,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          minimumSize: const Size(0, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Restore Purchases',
                          style: AppTextStyles.disclaimer.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                          ),
                        ),
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
                                onTap: () => setState(() => _activeIndex = i),
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
                                            ? const Color.fromARGB(
                                                255,
                                                213,
                                                193,
                                                133,
                                              )
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isActive
                                          ? [
                                              BoxShadow(
                                                color: Colors.amber.withAlpha(
                                                  100,
                                                ),
                                                blurRadius: 13,
                                                spreadRadius: 6,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: SubscriptionWidget(
                                      subscriptionName:
                                          productTitles[product.id] ??
                                          product.title,
                                      subscriptionCost: product.price,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  // Кнопки навигации + CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
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
                          onTap: _isProcessing
                              ? null
                              : () {
                                  final product =
                                      productsToShow[fixedActiveIndex];
                                  _buy(product);
                                },
                          child: Opacity(
                            opacity: _isProcessing ? 0.6 : 1.0,
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
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                  ),
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
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          'assets/icons/forw.png',
                          scale: 15,
                          color: const Color.fromARGB(149, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Unlimited access to Logic, Poetry, Silence & Flow. 3‑day free trial.'
                      'Auto‑renewing subscription.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.disclaimer.copyWith(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 1),
                ],
              ),
            ),
            if (_isProcessing)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
