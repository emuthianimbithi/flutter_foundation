import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/src/auth_state.dart';
import 'package:foundation_auth/src/providers/providers.dart';

class OrgSelectorPage extends ConsumerWidget {
  final String orgSelectionToken;
  final List<OrganizationOption> organizations;

  const OrgSelectorPage({
    super.key,
    required this.orgSelectionToken,
    required this.organizations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose organization')),
      body: ListView.separated(
        itemCount: organizations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final org = organizations[i];
          return ListTile(
            title: Text(org.name),
            subtitle: Text(org.slug),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).selectOrganization(
                    orgSelectionToken: orgSelectionToken,
                    orgSlug: org.slug,
                  );
            },
          );
        },
      ),
    );
  }
}
