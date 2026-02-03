class PaymentIntentModel {
  final String id;
  final int amountMinor; // cents
  final String currency; // e.g. "usd"
  final String? description;
  final String? clientSecret;

  const PaymentIntentModel({
    required this.id,
    required this.amountMinor,
    required this.currency,
    this.description,
    this.clientSecret,
  });
}
