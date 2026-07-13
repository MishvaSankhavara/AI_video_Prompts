import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/constants.dart';
import '../utils/common_utils.dart';

class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  String weeklyPrice = '\$4.99'; // Default fallback
  String yearlyPrice = '\$39.99'; // Default fallback

  bool isAvailable = false;
  List<ProductDetails> products = [];

  Future<void> init() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      CommonUtils.printLog('--- SubscriptionService: InAppPurchase not available ---');
      return;
    }

    // Set up purchase updates listener (required by in_app_purchase)
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      CommonUtils.printLog('--- SubscriptionService: Error listening to purchases: $error ---');
    });

    final Set<String> kIds = <String>{
      AppConstants.weeklySubscriptionId,
      AppConstants.yearlySubscriptionId,
    };

    final ProductDetailsResponse response = await _iap.queryProductDetails(kIds);

    if (response.notFoundIDs.isNotEmpty) {
      CommonUtils.printLog('--- SubscriptionService: Products not found: ${response.notFoundIDs} ---');
    }

    products = response.productDetails;
    for (var product in products) {
      CommonUtils.printLog('--- SubscriptionService: Found product: ${product.id} with price: ${product.price} ---');
      if (product.id == AppConstants.weeklySubscriptionId) {
        weeklyPrice = product.price;
      } else if (product.id == AppConstants.yearlySubscriptionId) {
        yearlyPrice = product.price;
      }
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          CommonUtils.printLog('--- SubscriptionService: Purchase error ---');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          CommonUtils.printLog('--- SubscriptionService: Purchase successful ---');
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> buySubscription({required bool isYearly}) async {
    if (!isAvailable) {
      CommonUtils.printLog('--- SubscriptionService: InAppPurchase not available ---');
      return;
    }

    final productId = isYearly 
        ? AppConstants.yearlySubscriptionId 
        : AppConstants.weeklySubscriptionId;

    ProductDetails? productToBuy;
    for (var product in products) {
      if (product.id == productId) {
        productToBuy = product;
        break;
      }
    }

    if (productToBuy != null) {
      CommonUtils.printLog('--- SubscriptionService: Launching Google Play purchase flow for $productId ---');
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productToBuy);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      CommonUtils.printLog('--- SubscriptionService: Product $productId not found for purchase ---');
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription.cancel();
  }
}
