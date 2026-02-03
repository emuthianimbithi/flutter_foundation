import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_i18n/foundation_i18n.dart';
import 'package:foundation_ui/foundation_ui.dart';

class I18nScreen extends ConsumerWidget {
  const I18nScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeService = LocaleService();
    final tokens = FoundationTheme.tokensOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('i18n')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current locale: ${localeService.locale ?? WidgetsBinding.instance.window.locale}'),
            SizedBox(height: tokens.space12),
            Text('Formatted number: ${NumberFormatters.currency(12345.67, symbol: '\$')}'),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Switch to fr',
              onPressed: () {
                localeService.setLocale(const Locale('fr'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Locale set to fr')));
              },
            ),
            SizedBox(height: tokens.space12),
            Text('RTL preview (context): ${RtlUtils.isRtl(context)}'),
          ],
        ),
      ),
    );
  }
}
