import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../theme/app_theme.dart';
import 'storage_service.dart';

class IAPService {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();
  IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  List<ProductDetails> products = [];
  bool _isAvailable = false;

  static const Set<String> _productIds = {
    AppConstants.iapVipId,
    AppConstants.iapVipSubscriptionId,
    AppConstants.iapCoinsPack1,
    AppConstants.iapCoinsPack2,
  };

  Future<void> init() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    // Listen to purchase stream
    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (_) {},
    );

    // Load products
    final response = await _iap.queryProductDetails(_productIds);
    products = response.productDetails;
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _deliverProduct(purchase);
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    switch (purchase.productID) {
      case AppConstants.iapVipId:
      case AppConstants.iapVipSubscriptionId:
        await StorageService.instance.setVip(true);
        await StorageService.instance.addCoins(200); // Bonus coins for VIP/premium
        break;
      case AppConstants.iapCoinsPack1:
        await StorageService.instance.addCoins(10);
        break;
      case AppConstants.iapCoinsPack2:
        await StorageService.instance.addCoins(100);
        break;
    }
  }

  ProductDetails? getProduct(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> buy(String productId) async {
    final product = getProduct(productId);
    if (product == null) return false;

    final param = PurchaseParam(productDetails: product);
    try {
      await _iap.buyNonConsumable(purchaseParam: param);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> buyCoins(String productId) async {
    final product = getProduct(productId);
    if (product == null) return false;

    final param = PurchaseParam(productDetails: product);
    try {
      await _iap.buyConsumable(purchaseParam: param);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  String getPrice(String productId) {
    final product = getProduct(productId);
    return product?.price ?? '—';
  }

  void dispose() {
    _purchaseSubscription.cancel();
  }
}

