enum PaymentStatus {
  initiated,
  pending,
  processing,
  succeeded,
  failed,
  cancelled,
}

class PaymentResult {
  final PaymentStatus status;
  final String? message;
  final String? transactionId;

  const PaymentResult({
    required this.status,
    this.message,
    this.transactionId,
  });

  bool get isSuccess => status == PaymentStatus.succeeded;
}
