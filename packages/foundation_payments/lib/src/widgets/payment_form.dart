import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../models/payment_method.dart';
import '../models/payment_result.dart';
import '../providers/payment_providers.dart';

class PaymentForm extends ConsumerStatefulWidget {
  final int amountMinor;
  final String currency;
  final String? description;
  final ValueChanged<String>? onSuccessTransactionId;

  const PaymentForm({
    super.key,
    required this.amountMinor,
    required this.currency,
    this.description,
    this.onSuccessTransactionId,
  });

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  PaymentMethod? _selected;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final methods = ref.watch(availablePaymentMethodsProvider);

    _selected ??= methods.first;

    return FoundationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pay', style: FoundationTheme.typeOf(context).h3),
          SizedBox(height: tokens.space12),
          Text('${_money(widget.amountMinor, widget.currency)}', style: FoundationTheme.typeOf(context).bodyStrong),
          if (widget.description != null) ...[
            SizedBox(height: tokens.space8),
            Text(widget.description!, style: FoundationTheme.typeOf(context).body),
          ],
          SizedBox(height: tokens.space16),
          _MethodPicker(
            methods: methods,
            selected: _selected!,
            onChanged: (m) => setState(() => _selected = m),
          ),
          SizedBox(height: tokens.space16),
          if (_error != null) ...[
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            SizedBox(height: tokens.space12),
          ],
          FoundationButton(
            label: _loading ? 'Processing...' : 'Pay now',
            onPressed: _loading ? null : _pay,
          ),
        ],
      ),
    );
  }

  Future<void> _pay() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final svc = ref.read(paymentServiceProvider);
      final intent = await svc.createPayment(
        amountMinor: widget.amountMinor,
        currency: widget.currency,
        description: widget.description,
      );
      final res = await svc.pollStatus(intentId: intent.id, interval: const Duration(seconds: 1), timeout: const Duration(seconds: 15));
      if (res.status == PaymentStatus.succeeded) {
        widget.onSuccessTransactionId?.call(res.transactionId ?? intent.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
        }
      } else if (res.status == PaymentStatus.cancelled) {
        setState(() => _error = res.message ?? 'Payment cancelled');
      } else {
        setState(() => _error = res.message ?? 'Payment failed');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _money(int minor, String currency) {
    final major = minor / 100.0;
    return '${currency.toUpperCase()} ${major.toStringAsFixed(2)}';
  }
}

class _MethodPicker extends StatelessWidget {
  final List<PaymentMethod> methods;
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const _MethodPicker({
    required this.methods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: methods
          .map(
            (m) => RadioListTile<PaymentMethod>(
              value: m,
              groupValue: selected,
              onChanged: (v) => v != null ? onChanged(v) : null,
              title: Text(m.label),
            ),
          )
          .toList(),
    );
  }
}
