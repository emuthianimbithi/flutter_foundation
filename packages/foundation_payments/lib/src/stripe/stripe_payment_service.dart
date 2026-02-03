import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:foundation_payments/src/models/payment_backend.dart';
import 'package:foundation_payments/src/models/payment_intent.dart';
import 'package:foundation_payments/src/models/payment_result.dart';
import 'package:foundation_payments/src/services/payment_service.dart';

enum PaymentFlowState {
  idle,
  creatingIntent,
  presentingSheet,
  success,
  failure,
  cancelled
}

/// Stripe implementation backed by a [PaymentBackend] that returns client secrets.
class StripePaymentService implements PaymentService {
  final PaymentBackend backend;
  final String merchantDisplayName;
  final stripe.Stripe _stripe;
  final ValueNotifier<PaymentFlowState> flowState =
      ValueNotifier(PaymentFlowState.idle);

  StripePaymentService({
    required this.backend,
    this.merchantDisplayName = 'Demo Store',
    stripe.Stripe? stripeInstance,
  }) : _stripe = stripeInstance ?? stripe.Stripe.instance;

  @override
  Future<PaymentIntentModel> createPayment({
    required int amountMinor,
    required String currency,
    String? description,
  }) async {
    flowState.value = PaymentFlowState.creatingIntent;
    final intent = await backend.createPaymentIntent(
      amountMinor: amountMinor,
      currency: currency,
      description: description,
    );
    return intent;
  }

  /// Present Stripe PaymentSheet. Falls back to a demo success path when
  /// the client secret is marked as `demo_`.
  Future<PaymentResult> presentPaymentSheet(PaymentIntentModel intent) async {
    if (_isDemo(intent)) {
      flowState.value = PaymentFlowState.presentingSheet;
      await Future.delayed(const Duration(milliseconds: 100));
      if (intent.clientSecret?.contains('cancel') ?? false) {
        flowState.value = PaymentFlowState.cancelled;
        return PaymentResult(
            status: PaymentStatus.cancelled, message: 'Demo cancel');
      }
      if (intent.clientSecret?.contains('fail') ?? false) {
        flowState.value = PaymentFlowState.failure;
        return PaymentResult(
            status: PaymentStatus.failed, message: 'Demo failure');
      }
      flowState.value = PaymentFlowState.success;
      return PaymentResult(
        status: PaymentStatus.succeeded,
        transactionId: intent.id,
        message: 'Demo payment succeeded',
      );
    }

    if (intent.clientSecret == null || intent.clientSecret!.isEmpty) {
      flowState.value = PaymentFlowState.failure;
      return const PaymentResult(
        status: PaymentStatus.failed,
        message: 'Stripe client secret missing. Configure your backend.',
      );
    }

    try {
      flowState.value = PaymentFlowState.presentingSheet;
      await _stripe.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret!,
          merchantDisplayName: merchantDisplayName,
        ),
      );
      await _stripe.presentPaymentSheet();
      flowState.value = PaymentFlowState.success;
      return PaymentResult(
          status: PaymentStatus.succeeded, transactionId: intent.id);
    } on stripe.StripeException catch (e) {
      if (e.error.code == stripe.FailureCode.Canceled) {
        flowState.value = PaymentFlowState.cancelled;
        return PaymentResult(
            status: PaymentStatus.cancelled, message: e.error.message);
      }
      flowState.value = PaymentFlowState.failure;
      return PaymentResult(
          status: PaymentStatus.failed, message: e.error.message);
    } catch (e) {
      flowState.value = PaymentFlowState.failure;
      return PaymentResult(status: PaymentStatus.failed, message: e.toString());
    }
  }

  @override
  Future<PaymentResult> confirmPayment(PaymentIntentModel intent) =>
      presentPaymentSheet(intent);

  @override
  Future<PaymentResult> pollStatus({
    required String intentId,
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 2),
  }) async {
    if (intentId.startsWith('demo_')) {
      return PaymentResult(
          status: PaymentStatus.succeeded, transactionId: intentId);
    }
    try {
      final pi = await _stripe.retrievePaymentIntent(intentId);
      final status = pi.status;
      switch (status) {
        case stripe.PaymentIntentsStatus.Succeeded:
          return PaymentResult(
              status: PaymentStatus.succeeded, transactionId: pi.id);
        case stripe.PaymentIntentsStatus.Processing:
          return const PaymentResult(status: PaymentStatus.processing);
        case stripe.PaymentIntentsStatus.RequiresPaymentMethod:
        case stripe.PaymentIntentsStatus.RequiresConfirmation:
          return const PaymentResult(
              status: PaymentStatus.pending, message: 'Awaiting confirmation');
        default:
          return PaymentResult(
              status: PaymentStatus.failed, message: status.name);
      }
    } on stripe.StripeException catch (e) {
      return PaymentResult(
          status: PaymentStatus.failed, message: e.error.message);
    } catch (e) {
      return PaymentResult(status: PaymentStatus.failed, message: e.toString());
    }
  }

  @override
  Future<void> cancel(String intentId) async {
    // No direct cancel via client SDK; surface as cancelled state.
    flowState.value = PaymentFlowState.cancelled;
  }

  bool _isDemo(PaymentIntentModel intent) =>
      intent.clientSecret?.startsWith('demo_') ?? false;
}
