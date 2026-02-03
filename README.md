# Flutter Foundation

A comprehensive Flutter component library for rapidly building B2B and consumer applications.

## Overview

Flutter Foundation is a monorepo containing modular packages that provide:

- **Networking** - gRPC, REST, WebSocket, MQTT, GraphQL, Firestore with retry, caching, and offline support
- **Authentication** - Multi-tenant SSO, OAuth, MFA, biometrics with full state management
- **Storage** - Secure storage, SQLite (Drift), preferences, org-scoped data isolation
- **Sync** - Offline-first architecture with conflict resolution
- **UI Components** - Themeable, white-label ready widgets for forms, data display, navigation
- **Integrations** - Maps, calendar, media, payments, push notifications
- **Infrastructure** - Routing, permissions, analytics, security, i18n

## Packages

### Core
| Package | Description |
|---------|-------------|
| `foundation_core` | Shared utilities, result types, extensions, logger |
| `foundation_config` | Environment management, app configuration, feature flags |
| `foundation_storage` | Secure storage, Drift DB, preferences, file storage |
| `foundation_sync` | Offline queue, conflict resolution, change tracking |

### Networking & Auth
| Package | Description |
|---------|-------------|
| `foundation_networking` | gRPC/REST clients, interceptors, retry, caching |
| `foundation_auth` | SSO integration, OAuth, MFA, session management |

### Infrastructure
| Package | Description |
|---------|-------------|
| `foundation_routing` | go_router setup, deep links, route guards |
| `foundation_notifications` | FCM, local notifications, routing |
| `foundation_permissions` | Unified permission handling with UI |
| `foundation_analytics` | Event logging, crash reporting |
| `foundation_security` | Certificate pinning, root detection |
| `foundation_i18n` | Localization, RTL support |

### UI & Features
| Package | Description |
|---------|-------------|
| `foundation_ui` | Theme system, white-labeling, core widgets |
| `foundation_forms` | Form inputs, validation, file uploads |
| `foundation_onboarding` | Intro sliders, coach marks, tooltips |
| `foundation_device` | Camera, scanner, biometrics, share |
| `foundation_maps` | Google Maps, Mapbox, geofencing |
| `foundation_calendar` | Calendar views, scheduling |
| `foundation_media` | Image, video, audio players |
| `foundation_chat` | Messaging UI components |
| `foundation_payments` | Stripe, PayPal, in-app purchases |

## Getting Started

### Prerequisites

- Flutter SDK >= 3.19.0
- Dart SDK >= 3.3.0
- Melos (`dart pub global activate melos`)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/emuthianimbithi/flutter_foundation.git
cd flutter_foundation
```

2. Bootstrap the workspace:
```bash
melos bootstrap
```

3. Run code generation:
```bash
melos run generate
```

### Using in Your Project

Add the packages you need to your `pubspec.yaml`:

```yaml
dependencies:
  foundation_core:
    git:
      url: https://github.com/emuthianimbithi/flutter_foundation
      path: packages/foundation_core
      ref: main  # or specific version tag

  foundation_auth:
    git:
      url: https://github.com/emuthianimbithi/flutter_foundation
      path: packages/foundation_auth
      ref: main

  foundation_ui:
    git:
      url: https://github.com/emuthianimbithi/flutter_foundation
      path: packages/foundation_ui
      ref: main

  # Your generated proto package
  marulla_protos:
    git:
      url: https://github.com/emuthianimbithi/protos
      path: gen/dart
```

### Quick Start Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_ui/foundation_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize foundation
  await FoundationConfig.initialize(
    environment: Environment.production,
    appId: 'your-app-id',
    grpcHost: 'api.yourcompany.com',
    grpcPort: 443,
  );

  runApp(
    ProviderScope(
      child: FoundationApp(
        theme: FoundationTheme.light(),
        darkTheme: FoundationTheme.dark(),
        // Optional: white-label config
        whiteLabel: WhiteLabelConfig(
          primaryColor: Colors.blue,
          logoAsset: 'assets/logo.png',
        ),
        home: const AuthGate(
          authenticated: HomePage(),
          unauthenticated: LoginPage(),
        ),
      ),
    ),
  );
}
```

## Development

### Common Commands

```bash
# Bootstrap all packages
melos bootstrap

# Run all tests
melos run test

# Run analysis
melos run analyze

# Format code
melos run format

# Generate code (build_runner)
melos run generate

# Run CI checks
melos run ci

# Clean all
melos run clean
```

### Package Development

When developing a specific package:

```bash
cd packages/foundation_auth
flutter pub get
flutter test
dart run build_runner build
```

### Adding a New Package

1. Create the package directory:
```bash
mkdir -p packages/foundation_newpackage/lib/src
```

2. Create `pubspec.yaml` following the existing patterns

3. Add to workspace by running:
```bash
melos bootstrap
```

## Architecture

### Dependency Graph

```
┌─────────────────────────────────────────────────────────────┐
│                        YOUR APP                              │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌───────────────┐
│ foundation_ui │   │ foundation_auth │   │ foundation_*  │
└───────┬───────┘   └────────┬────────┘   └───────┬───────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                             ▼
              ┌──────────────────────────┐
              │  foundation_networking   │
              └────────────┬─────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
      ┌────────────┐ ┌──────────┐ ┌─────────────┐
      │ foundation │ │foundation│ │ foundation  │
      │  _storage  │ │ _config  │ │   _core     │
      └────────────┘ └──────────┘ └─────────────┘
                           │
                           ▼
              ┌──────────────────────────┐
              │     marulla_protos       │
              │   (generated gRPC stubs) │
              └──────────────────────────┘
```

### State Management

All packages use Riverpod for state management. Key providers are exported from each package:

```dart
// Auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);

// Current user
final currentUserProvider = Provider<User?>(...);

// Current organization
final currentOrgProvider = Provider<Organization?>(...);

// Feature flags
final featureProvider = Provider.family<bool, String>(...);
```

### Offline-First

The foundation supports offline-first architecture:

1. **Optimistic Updates** - UI updates immediately
2. **Sync Queue** - Operations queued when offline
3. **Conflict Resolution** - Configurable strategies (last-write-wins, merge, manual)
4. **Change Tracking** - Local changes tracked for sync

## Configuration

### Environment Setup

```dart
await FoundationConfig.initialize(
  environment: Environment.production,
  appId: 'your-app-id',
  
  // gRPC
  grpcHost: 'api.yourcompany.com',
  grpcPort: 443,
  grpcUseTls: true,
  
  // Optional REST fallback
  restBaseUrl: 'https://api.yourcompany.com',
  
  // Feature flags
  enableOfflineMode: true,
  enableAnalytics: true,
  enableCrashReporting: true,
  
  // Timeouts
  connectionTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
);
```

### White Labeling

```dart
final config = WhiteLabelConfig(
  appName: 'Client App',
  primaryColor: Color(0xFF1E88E5),
  secondaryColor: Color(0xFF43A047),
  logoAsset: 'assets/client_logo.png',
  fontFamily: 'ClientFont',
  
  // Per-screen customization
  loginBackground: 'assets/client_login_bg.png',
  splashLogo: 'assets/client_splash.png',
);
```

## Testing

Each package includes comprehensive tests:

```bash
# Run all tests with coverage
melos run test

# Run specific package tests
cd packages/foundation_auth
flutter test --coverage

# Run integration tests
melos run test:integration
```

### Mocking

Packages export mock implementations for testing:

```dart
import 'package:foundation_auth/testing.dart';

final mockAuthService = MockAuthService();
final mockTokenManager = MockTokenManager();
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

We use conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance

## License

This project is proprietary software. All rights reserved.

## Support

For questions and support, contact the development team.
