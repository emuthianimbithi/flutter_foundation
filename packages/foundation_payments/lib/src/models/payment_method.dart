enum PaymentMethodType { card, paypal, inAppPurchase }

class PaymentMethod {
  final PaymentMethodType type;
  final String label;

  const PaymentMethod(this.type, this.label);
}