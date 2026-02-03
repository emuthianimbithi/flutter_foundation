import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_intent.dart';
import '../providers/payment_providers.dart';
import 'package:foundation_ui/foundation_ui.dart';

class PaymentForm extends ConsumerWidget {
  final PaymentIntent intent;

  const PaymentForm({super.key, required this.intent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FoundationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(intent.description,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FoundationButton.primary(
            label:
                'Pay ${intent.currency.toUpperCase()} ${(intent.amount / 100).toStringAsFixed(2)}',
            onPressed: () async {
              final adapter = ref.read(paymentAdapterProvider);
              final result = await adapter.pay(intent);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.status.name)),
              );
            },
          ),
        ],
      ),
    );
  }
}
