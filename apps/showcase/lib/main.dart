import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_analytics/foundation_analytics.dart';
import 'package:foundation_calendar/foundation_calendar.dart';
import 'package:foundation_chat/foundation_chat.dart';
import 'package:foundation_forms/foundation_forms.dart';
import 'package:foundation_media/foundation_media.dart';
import 'package:foundation_notifications/foundation_notifications.dart';
import 'package:foundation_payments/foundation_payments.dart';
import 'package:foundation_ui/foundation_ui.dart';
import 'package:marulla_protos/marulla/reja/v1/forms.pb.dart' as pb;

void main() {
  runApp(
    ProviderScope(
      overrides: [
        // Seed calendar events and selection.
        selectedDateProvider.overrideWith((ref) => DateTime.now()),
        eventsProvider.overrideWith((ref) => _demoEvents),

        // Seed chat messages.
        messagesProvider.overrideWith((ref) => _initialMessages),

        // Use a safe demo payment service so UI can complete without hitting a backend.
        paymentServiceProvider.overrideWithValue(_DemoPaymentService()),
      ],
      child: const ShowcaseApp(),
    ),
  );
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Foundation Showcase',
      theme: FoundationTheme.materialTheme(
        scheme: const FoundationColorScheme(
            seed: Colors.teal, brightness: Brightness.light),
      ),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({super.key});

  static final List<_Destination> _destinations = [
    _Destination(
      title: 'UI Gallery',
      description: 'Buttons, cards, text fields from foundation_ui.',
      icon: Icons.palette_outlined,
      builder: (_) => const _UiGalleryScreen(),
    ),
    _Destination(
      title: 'Notifications',
      description: 'Payload + route resolution using foundation_notifications.',
      icon: Icons.notifications_outlined,
      builder: (_) => const _NotificationsScreen(),
    ),
    _Destination(
      title: 'Analytics',
      description: 'Track events & log crashes via foundation_analytics.',
      icon: Icons.bar_chart_outlined,
      builder: (_) => const _AnalyticsScreen(),
    ),
    _Destination(
      title: 'Media',
      description:
          'Image picker & cached network images from foundation_media.',
      icon: Icons.photo_library_outlined,
      builder: (_) => const _MediaScreen(),
    ),
    _Destination(
      title: 'Forms',
      description: 'Dynamic form renderer driven by marulla_protos.',
      icon: Icons.description_outlined,
      builder: (_) => const _FormsScreen(),
    ),
    _Destination(
      title: 'Calendar',
      description: 'Month view with events (foundation_calendar).',
      icon: Icons.calendar_month_outlined,
      builder: (_) => const _CalendarScreen(),
    ),
    _Destination(
      title: 'Chat',
      description: 'Message list, bubbles, input (foundation_chat).',
      icon: Icons.chat_bubble_outline,
      builder: (_) => const _ChatScreen(),
    ),
    _Destination(
      title: 'Payments',
      description: 'Payment form with demo service (foundation_payments).',
      icon: Icons.payment_outlined,
      builder: (_) => const _PaymentsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final type = FoundationTheme.typeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Foundation Showcase')),
      body: ListView.separated(
        padding: EdgeInsets.all(tokens.space16),
        itemCount: _destinations.length,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
        itemBuilder: (context, index) {
          final d = _destinations[index];
          return FoundationCard(
            child: ListTile(
              leading: Icon(d.icon),
              title: Text(d.title, style: type.h3),
              subtitle: Text(d.description, style: type.body),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: d.builder)),
            ),
          );
        },
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}

// ─────────────────────────────────────────────────────────────────────────────
// UI GALLERY
// ─────────────────────────────────────────────────────────────────────────────

class _UiGalleryScreen extends StatelessWidget {
  const _UiGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final type = FoundationTheme.typeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('UI Gallery')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoundationButton(label: 'Primary Action', onPressed: () {}),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Secondary',
              variant: FoundationButtonVariant.secondary,
              onPressed: () {},
            ),
            SizedBox(height: tokens.space16),
            FoundationTextField(
              label: 'Email',
              hint: 'you@example.com',
              onChanged: (_) {},
            ),
            SizedBox(height: tokens.space16),
            Text('Cards', style: type.h3),
            SizedBox(height: tokens.space8),
            FoundationCard(
              child: Padding(
                padding: EdgeInsets.all(tokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FoundationCard', style: type.h3),
                    SizedBox(height: tokens.space8),
                    Text('Reusable card with theme spacing and radius.',
                        style: type.body),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATIONS
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen({super.key});

  static final List<NotificationPayload> _payloads = [
    const NotificationPayload(
      title: 'Weekly Summary',
      body: 'Your metrics are ready.',
      data: {'route': '/analytics', 'week': '34'},
    ),
    const NotificationPayload(
      title: 'New Form Assigned',
      body: 'Inspection checklist v2',
      data: {'route': '/forms', 'template_id': 'tmpl_123'},
    ),
    const NotificationPayload(
      title: 'Chat message',
      body: 'New message in support',
      data: {'route': '/chat', 'chat_id': 'support'},
    ),
  ];

  NotificationRoute? _resolve(NotificationPayload payload) {
    final route = payload.data['route']?.toString() ?? '/';
    final params = {
      for (final entry in payload.data.entries)
        if (entry.key != 'route') entry.key: entry.value.toString(),
    };
    return NotificationRoute(route, params: params);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final type = FoundationTheme.typeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: EdgeInsets.all(tokens.space16),
        itemCount: _payloads.length,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
        itemBuilder: (context, index) {
          final p = _payloads[index];
          final route = _resolve(p);
          return FoundationCard(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(p.title ?? 'Notification', style: type.body),
              subtitle: Text(
                '${p.body ?? ''}\nRoute: ${route?.location} ${route?.params}',
                style: type.caption,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyticsScreen extends ConsumerStatefulWidget {
  const _AnalyticsScreen({super.key});

  @override
  ConsumerState<_AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<_AnalyticsScreen> {
  int _eventCount = 0;
  String _lastLog = 'Tap buttons to send events';

  Future<void> _track() async {
    final svc = ref.read(analyticsServiceProvider);
    await svc
        .track('demo_event', params: {'ts': DateTime.now().toIso8601String()});
    setState(() {
      _eventCount += 1;
      _lastLog = 'Sent demo_event ($_eventCount)';
    });
  }

  Future<void> _crash() async {
    final crash = ref.read(crashServiceProvider);
    try {
      throw StateError('Demo crash for showcase');
    } catch (e, s) {
      await crash.record(e, s, reason: 'Showcase crash button');
      setState(() => _lastLog = 'Recorded non-fatal error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final type = FoundationTheme.typeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Events recorded', style: type.h3),
            SizedBox(height: tokens.space8),
            Text('$_eventCount', style: type.h1),
            SizedBox(height: tokens.space16),
            FoundationButton(label: 'Track demo_event', onPressed: _track),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Record non-fatal crash',
              variant: FoundationButtonVariant.secondary,
              onPressed: _crash,
            ),
            SizedBox(height: tokens.space16),
            Text(_lastLog, style: type.body),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEDIA
// ─────────────────────────────────────────────────────────────────────────────

class _MediaScreen extends StatelessWidget {
  const _MediaScreen({super.key});

  static const _urls = [
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1522199710521-72d69614c702?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1500048993953-d23a436266cf?auto=format&fit=crop&w=600&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Media')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagePickerView(
              onPick: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pick image tapped (demo)')),
              ),
            ),
            SizedBox(height: tokens.space16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _urls.length,
                itemBuilder: (_, i) => NetworkImageView(url: _urls[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORMS (marulla_protos + foundation_forms)
// ─────────────────────────────────────────────────────────────────────────────

class _FormsScreen extends StatefulWidget {
  const _FormsScreen({super.key});

  @override
  State<_FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<_FormsScreen> {
  late final pb.FormTemplate _template;
  Map<String, dynamic> _latestValues = const {};

  @override
  void initState() {
    super.initState();
    _template = _buildSampleTemplate();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final type = FoundationTheme.typeOf(context);
    final fields = _mapFields(_template.fields);

    return Scaffold(
      appBar: AppBar(title: const Text('Forms (marulla_protos)')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Template: ${_template.name}', style: type.h3),
            SizedBox(height: tokens.space8),
            Text('Fields: ${_template.fields.length}', style: type.body),
            SizedBox(height: tokens.space16),
            Expanded(
              child: DynamicFormRenderer(
                fields: fields,
                onChanged: (v) => setState(() => _latestValues = v),
                onSubmitted: (v) => setState(() => _latestValues = v),
              ),
            ),
            SizedBox(height: tokens.space12),
            Text('Latest values:', style: type.bodyStrong),
            Text(_latestValues.toString(), style: type.caption),
          ],
        ),
      ),
    );
  }

  pb.FormTemplate _buildSampleTemplate() {
    return pb.FormTemplate(
      id: 'tmpl_123',
      name: 'Site Inspection',
      status: pb.FormTemplateStatus.FORM_TEMPLATE_STATUS_PUBLISHED,
      fields: [
        pb.FormField()
          ..id = 'fld_name'
          ..label = 'Name'
          ..type = pb.FormFieldType.FORM_FIELD_TYPE_TEXT
          ..required = true
          ..placeholder = 'Full name',
        pb.FormField()
          ..id = 'fld_date'
          ..label = 'Visit Date'
          ..type = pb.FormFieldType.FORM_FIELD_TYPE_DATE,
        pb.FormField()
          ..id = 'fld_rating'
          ..label = 'Site Score'
          ..type = pb.FormFieldType.FORM_FIELD_TYPE_RATING
          ..helpText = '1-5',
        pb.FormField()
          ..id = 'fld_photo'
          ..label = 'Photo'
          ..type = pb.FormFieldType.FORM_FIELD_TYPE_PHOTO,
        pb.FormField()
          ..id = 'fld_location'
          ..label = 'Location'
          ..type = pb.FormFieldType.FORM_FIELD_TYPE_LOCATION,
      ],
    );
  }

  List<DynamicFormField> _mapFields(List<pb.FormField> fields) {
    DynamicFieldType _mapType(pb.FormFieldType t) {
      switch (t) {
        case pb.FormFieldType.FORM_FIELD_TYPE_TEXT:
          return DynamicFieldType.text;
        case pb.FormFieldType.FORM_FIELD_TYPE_TEXTAREA:
          return DynamicFieldType.textarea;
        case pb.FormFieldType.FORM_FIELD_TYPE_NUMBER:
          return DynamicFieldType.number;
        case pb.FormFieldType.FORM_FIELD_TYPE_EMAIL:
          return DynamicFieldType.email;
        case pb.FormFieldType.FORM_FIELD_TYPE_PHONE:
          return DynamicFieldType.phone;
        case pb.FormFieldType.FORM_FIELD_TYPE_DATE:
          return DynamicFieldType.date;
        case pb.FormFieldType.FORM_FIELD_TYPE_TIME:
          return DynamicFieldType.time;
        case pb.FormFieldType.FORM_FIELD_TYPE_DATETIME:
          return DynamicFieldType.dateTime;
        case pb.FormFieldType.FORM_FIELD_TYPE_SELECT:
          return DynamicFieldType.select;
        case pb.FormFieldType.FORM_FIELD_TYPE_MULTI_SELECT:
          return DynamicFieldType.multiSelect;
        case pb.FormFieldType.FORM_FIELD_TYPE_RADIO:
          return DynamicFieldType.radio;
        case pb.FormFieldType.FORM_FIELD_TYPE_CHECKBOX:
          return DynamicFieldType.checkbox;
        case pb.FormFieldType.FORM_FIELD_TYPE_TOGGLE:
          return DynamicFieldType.toggle;
        case pb.FormFieldType.FORM_FIELD_TYPE_RATING:
          return DynamicFieldType.rating;
        case pb.FormFieldType.FORM_FIELD_TYPE_PHOTO:
          return DynamicFieldType.photo;
        case pb.FormFieldType.FORM_FIELD_TYPE_SIGNATURE:
          return DynamicFieldType.signature;
        case pb.FormFieldType.FORM_FIELD_TYPE_LOCATION:
          return DynamicFieldType.location;
        case pb.FormFieldType.FORM_FIELD_TYPE_BARCODE:
          return DynamicFieldType.barcode;
        default:
          return DynamicFieldType.text;
      }
    }

    DynamicFieldValidation? _mapValidation(pb.FormFieldValidation? v) {
      if (v == null) return null;
      return DynamicFieldValidation(
        minLength: v.hasMinLength() ? v.minLength : null,
        maxLength: v.hasMaxLength() ? v.maxLength : null,
        minValue: v.hasMinValue() ? v.minValue : null,
        maxValue: v.hasMaxValue() ? v.maxValue : null,
        pattern: v.hasPattern() ? v.pattern : null,
        errorMessage: v.hasErrorMessage() ? v.errorMessage : null,
      );
    }

    return fields
        .map(
          (f) => DynamicFormField(
            id: f.id,
            label: f.label,
            type: _mapType(f.type),
            required: f.required,
            placeholder: f.hasPlaceholder() ? f.placeholder : null,
            helpText: f.hasHelpText() ? f.helpText : null,
            defaultValue: f.hasDefaultValue() ? f.defaultValue : null,
            order: f.hasOrder() ? f.order : null,
            options: f.options
                .map((o) => DynamicFieldOption(value: o.value, label: o.label))
                .toList(),
            validation: _mapValidation(f.hasValidation() ? f.validation : null),
            section: f.hasSection() ? f.section : null,
          ),
        )
        .toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarScreen extends ConsumerWidget {
  const _CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);
    final t = FoundationTheme.typeOf(context);
    final selected = ref.watch(selectedDateProvider);
    final events = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          Expanded(child: MonthCalendarView(weekStartsOn: DateTime.monday)),
          Padding(
            padding: EdgeInsets.all(tokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Selected: ${selected.toLocal().toIso8601String().split("T").first}',
                    style: t.bodyStrong),
                SizedBox(height: tokens.space8),
                Text('Events today', style: t.h3),
                ...events
                    .where((e) =>
                        e.start.year == selected.year &&
                        e.start.month == selected.month &&
                        e.start.day == selected.day)
                    .map((e) => Text('• ${e.title}', style: t.body))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _demoEvents = <CalendarEvent>[
  CalendarEvent(
    id: 'ev1',
    title: 'Team sync',
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(hours: 1)),
  ),
  CalendarEvent(
    id: 'ev2',
    title: 'Site inspection',
    start: DateTime.now().add(const Duration(days: 1)),
    end: DateTime.now().add(const Duration(days: 1, hours: 2)),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// CHAT
// ─────────────────────────────────────────────────────────────────────────────

class _ChatScreen extends ConsumerWidget {
  const _ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(tokens.space12),
              child: const MessageList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.space12),
            child: ChatInput(
              onSend: (text) {
                final id = Random().nextInt(999999).toString();
                ref.read(messagesProvider.notifier).state = [
                  ChatMessage(
                    id: id,
                    senderId: 'me',
                    text: text,
                    timestamp: DateTime.now(),
                    isMine: true,
                  ),
                  ...ref.read(messagesProvider),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}

final _initialMessages = <ChatMessage>[
  ChatMessage(
    id: 'm1',
    senderId: 'bot',
    text: 'Welcome to foundation_chat!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    isMine: false,
  ),
  ChatMessage(
    id: 'm2',
    senderId: 'me',
    text: 'Hi there 👋',
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    isMine: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENTS
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentsScreen extends ConsumerStatefulWidget {
  const _PaymentsScreen({super.key});

  @override
  ConsumerState<_PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<_PaymentsScreen> {
  String _status = 'Awaiting payment';

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final t = FoundationTheme.typeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentForm(
              amountMinor: 2599,
              currency: 'usd',
              description: 'Pro subscription',
              onSuccessTransactionId: (tx) =>
                  setState(() => _status = 'Paid: $tx'),
            ),
            SizedBox(height: tokens.space16),
            Text('Status: $_status', style: t.bodyStrong),
          ],
        ),
      ),
    );
  }
}

class _DemoPaymentService implements PaymentService {
  @override
  Future<void> cancel(String intentId) async {}

  @override
  Future<PaymentIntentModel> createPayment({
    required int amountMinor,
    required String currency,
    String? description,
  }) async {
    return PaymentIntentModel(
      id: 'pi_demo_${DateTime.now().millisecondsSinceEpoch}',
      amountMinor: amountMinor,
      currency: currency,
      description: description,
    );
  }

  @override
  Future<PaymentResult> pollStatus({
    required String intentId,
    Duration interval = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return PaymentResult(
        status: PaymentStatus.succeeded, transactionId: 'txn_$intentId');
  }
}
