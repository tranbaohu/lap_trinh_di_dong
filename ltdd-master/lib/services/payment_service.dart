class PaymentService {
  static Future<Map<String, dynamic>> createPaymentIntent(
      double amount,
      String currency,
      ) async {
    return {
      'amount': (amount * 100).toInt(),
      'currency': currency,
      'status': 'created',
    };
  }

  static Future<void> initializeStripe(String publishableKey) async {
  }

  static Future<PaymentResult> processPayment(
      double amount,
      String currency,
      ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return PaymentResult.success({
        'amount': amount,
        'currency': currency,
        'status': 'success',
      });
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }
}

class PaymentResult {
  final bool success;
  final String? error;
  final dynamic data;

  PaymentResult.success(this.data)
      : success = true,
        error = null;

  PaymentResult.failure(this.error)
      : success = false,
        data = null;
}