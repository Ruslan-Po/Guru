import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:guru/stiles/app_titles.dart';
import 'package:guru/widgets/subscription_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

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

  final List<String> productOrder = const [
    'guru_weekly',
    'guru_monthly',
    'guru_quarterly',
  ];

  final Map<String, String> productTitles = const {
    'guru_weekly': 'Weekly',
    'guru_monthly': 'Monthly',
    'guru_quarterly': 'Quarterly',
  };

  final Map<String, String> productImages = const {
    'guru_weekly': 'assets/subscroption_icons/weekly.png',
    'guru_monthly': 'assets/subscroption_icons/monthly.png',
    'guru_quarterly': 'assets/subscroption_icons/quarterly.png',
  };

  final Map<String, String> productDescriptions = const {
    'guru_weekly': 'Full access for 1 week',
    'guru_monthly': 'Full access for 1 month',
    'guru_quarterly': 'Full access for 3 months',
  };

  DateTime _lastSnackAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastSnackMsg;
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
    _isProcessing = false; // ✅ сброс при закрытии экрана
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

    final byId = {for (final p in response.productDetails) p.id: p};
    final ordered = <ProductDetails>[
      for (final id in productOrder)
        if (byId[id] != null) byId[id]!,
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

  void _buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    _setProcessing(true);
    try {
      _iap.buyNonConsumable(purchaseParam: param);
    } finally {
      _setProcessing(false); // ✅ сброс даже если покупка неудачная
    }
  }

  Future<void> _restorePurchases() async {
    _showSnack('Restoring purchases...');
    _setProcessing(true);

    try {
      if (Platform.isIOS) {
        final skAddition = _iap
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await skAddition.sync();
        await skAddition.refreshPurchaseVerificationData();
      }
      await _iap.restorePurchases();
      await Future.delayed(const Duration(seconds: 4));

      if (!_isPremium) {
        _showSnack('No active purchases to restore.');
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      _showSnack('Restore failed. Please try again.');
    } finally {
      _setProcessing(false); // ✅ сброс в любом случае
    }
  }

  String? _stablePurchaseId(PurchaseDetails p) {
    return p.purchaseID?.isNotEmpty == true
        ? p.purchaseID
        : p.verificationData.serverVerificationData.isNotEmpty
        ? p.verificationData.serverVerificationData
        : null;
  }

  bool _wasHandled(PurchaseDetails p) {
    final id = _stablePurchaseId(p);
    if (id == null) return false;
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
            } catch (_) {}
          }
          break;
        case PurchaseStatus.restored:
          anyRestored = true;
          hasPremium = true;
          if (purchase.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchase);
            } catch (_) {}
          }
          break;
      }
    }

    await _savePremiumStatus(hasPremium);
    _setProcessing(false);

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
    if (_lastSnackMsg == msg && now.difference(_lastSnackAt) < dedupe) return;
    _lastSnackMsg = msg;
    _lastSnackAt = now;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  String _periodLabel(String id) {
    switch (id) {
      case 'guru_weekly':
        return 'per week';
      case 'guru_monthly':
        return 'per month';
      case 'guru_quarterly':
        return 'per 3 months';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonMaxWidth = screenWidth * 0.8;
    final productsToShow = _products;

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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Color(0xFF000000), Color(0xFF4D574E)],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                          if (_isPremium)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text(
                                'Premium is active',
                                style: TextStyle(
                                  color: Color.fromARGB(200, 255, 193, 7),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unlock Guru Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Access all 4 modes — Logic, Poetry, Silence & Flow — without limits.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFCFE9E0),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _BenefitChip(label: 'Unlimited Q&A'),
                          SizedBox(width: 8),
                          _BenefitChip(label: 'All 4 modes'),
                          SizedBox(width: 8),
                          _BenefitChip(label: 'No ads'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Image.asset(
                            productImages[activeProduct.id] ??
                                'assets/transparent.png',
                            key: ValueKey(activeProduct.id),
                            scale: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 160,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(productsToShow.length, (i) {
                            final product = productsToShow[i];
                            final isActive = fixedActiveIndex == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _activeIndex = i),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(44),
                                      border: Border.all(
                                        color: isActive
                                            ? const Color(0xFFD5C185)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
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
                      const SizedBox(height: 6),
                      Text(
                        productDescriptions[activeProduct.id] ??
                            activeProduct.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Without an active subscription, modes and answers are not available.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.disclaimer.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: buttonMaxWidth),
                          child: GestureDetector(
                            onTap: _isProcessing
                                ? null
                                : () => _buy(activeProduct),
                            child: Opacity(
                              opacity: _isProcessing ? 0.6 : 1.0,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth < 400 ? 14 : 28,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(167, 247, 226, 251),
                                      Color(0xFFD5C185),
                                      Color.fromARGB(115, 226, 231, 239),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Continue ',
                                        style: TextStyle(
                                          color: Color(0xFF090000),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        activeProduct.price,
                                        style: const TextStyle(
                                          color: Color(0xFF090000),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _periodLabel(activeProduct.id),
                                        style: const TextStyle(
                                          color: Color(0xFF090000),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: _restorePurchases,
                          child: Text(
                            'Restore Purchases',
                            style: AppTextStyles.disclaimer.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '3-day free trial for new users. Auto-renews unless canceled at least 24 hours before the end of the period.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.disclaimer.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 16),
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
                    ],
                  ),
                ),
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

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
