import 'package:flutter/material.dart';
import 'package:foundation_payments/foundation_payments.dart';
import 'package:foundation_ui/foundation_ui.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: EdgeInsets.all(tokens.space16),
        children: [
          const Text('Note: Stripe/PayPal require backend + SDK wiring. This screen demonstrates the UI + interface.'),
          SizedBox(height: tokens.space12),
          PaymentForm(
            amountMinor: 2599,
            currency: 'kes',
            description: 'Demo purchase',
            onSuccessTransactionId: (id) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paid: $id')));
            },
          ),
        ],
      ),
    );
  }
}
