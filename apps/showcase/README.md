# Showcase (Flutter Foundation)

This demo app wires together the Foundation packages plus the generated Marulla protos.

## Setup

```bash
cd apps/showcase
flutter create . --platforms=web   # only needed once to add web scaffolding
flutter pub get
flutter run -d chrome
```

## Notes
- We override `protobuf` to 4.2.0 so the generated `marulla_protos` (tag `0.0.1`) build cleanly; the generated code relies on helper methods that remain in 4.2.x.
- All data is local/demo; no network calls are made.
- Routes: UI Gallery, Notifications, Analytics, Media, Forms (using marulla_protos), Calendar, Chat, Payments.
