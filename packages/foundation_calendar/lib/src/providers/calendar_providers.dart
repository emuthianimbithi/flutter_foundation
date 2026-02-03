import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final eventsProvider = StateProvider<List<CalendarEvent>>((ref) => const []);