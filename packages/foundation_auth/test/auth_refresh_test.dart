import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_auth/src/token_manager.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_networking/foundation_networking.dart';
import 'package:grpc/grpc.dart';

class _MockTokenManager extends Mock implements TokenManager {}

class _FakeGrpcFactory extends GrpcChannelFactory {
  _FakeGrpcFactory()
      : super(
            config: const GrpcConfig(
                host: 'localhost', port: 50051, useTls: false));
  @override
  ClientChannel getChannel() => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(const AuthState.unauthenticated());
  });

  group('AuthService refresh coalescing', () {
    test('two refresh calls share one backend invocation', () async {
      final tokenManager = _MockTokenManager();
      when(() => tokenManager.getRefreshToken())
          .thenAnswer((_) async => 'refresh');
      when(() => tokenManager.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            accessExpiry: any(named: 'accessExpiry'),
            refreshExpiry: any(named: 'refreshExpiry'),
            orgSlug: any(named: 'orgSlug'),
            userId: any(named: 'userId'),
            role: any(named: 'role'),
          )).thenAnswer((_) async {});
      when(() => tokenManager.loadSnapshot())
          .thenAnswer((_) async => const TokenSnapshot(
                accessToken: 'a1',
                refreshToken: 'r1',
                accessExpiry: null,
                refreshExpiry: null,
                orgSlug: 'org',
                userId: 'u',
                role: 'user',
              ));

      var calls = 0;
      Future<AuthState> refreshOverride() async {
        calls++;
        return const AuthState.authenticated(
          userId: 'u',
          orgSlug: 'org',
          features: [],
          role: 'user',
          accessToken: 'new_access',
          refreshToken: 'new_refresh',
        );
      }

      final service = AuthService(
        channelFactory: _FakeGrpcFactory(),
        tokenManager: tokenManager,
        appConfig:
            const AppConfig(environment: Environment.development, appId: 'app'),
        refreshOverride: refreshOverride,
      );

      final results = await Future.wait([service.refresh(), service.refresh()]);
      expect(calls, 1);
      expect(results[0].accessToken, 'new_access');
      expect(results[1].accessToken, 'new_access');
    });
  });

  group('SessionManager refresh leeway', () {
    test('refresh triggers when access expiring within leeway', () async {
      final tokenManager = _MockTokenManager();
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      when(() => tokenManager.loadSnapshot())
          .thenAnswer((_) async => TokenSnapshot(
                accessToken: 'a',
                refreshToken: 'r',
                accessExpiry: now.add(const Duration(seconds: 10)),
                refreshExpiry: now.add(const Duration(minutes: 5)),
                orgSlug: 'org',
                userId: 'u',
                role: 'user',
              ));

      final authService = _MockAuthService();
      when(() => authService.refresh())
          .thenAnswer((_) async => const AuthState.authenticated(
                userId: 'u',
                orgSlug: 'org',
                features: [],
                role: 'user',
                accessToken: 'new',
                refreshToken: 'rr',
              ));

      final manager = SessionManager(
        tokenManager: tokenManager,
        authService: authService,
        options: const AuthOptions(refreshLeeway: Duration(seconds: 30)),
        now: () => now,
      );

      final state = await manager.restore();
      expect(state.accessToken, 'new');
      verify(() => authService.refresh()).called(1);
    });

    test('no refresh when access is valid beyond leeway', () async {
      final tokenManager = _MockTokenManager();
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      when(() => tokenManager.loadSnapshot())
          .thenAnswer((_) async => TokenSnapshot(
                accessToken: 'a',
                refreshToken: 'r',
                accessExpiry: now.add(const Duration(minutes: 5)),
                refreshExpiry: now.add(const Duration(minutes: 10)),
                orgSlug: 'org',
                userId: 'u',
                role: 'user',
              ));

      final authService = _MockAuthService();

      final manager = SessionManager(
        tokenManager: tokenManager,
        authService: authService,
        options: const AuthOptions(refreshLeeway: Duration(seconds: 30)),
        now: () => now,
      );

      final state = await manager.restore();
      expect(state.accessToken, 'a');
      verifyNever(() => authService.refresh());
    });
  });

  group('Logout clears storage when configured', () {
    test('logout calls StorageInitializer.clearAll when enabled', () async {
      var cleared = false;
      final controller = AuthController(
        authService: _MockAuthService(),
        tokenManager: _MockTokenManager(),
        options: const AuthOptions(logoutClearsStorage: true),
        clearStorage: () async => cleared = true,
      );

      await controller.logout();
      expect(cleared, isTrue);
    });
  });
}

class _MockAuthService extends Mock implements AuthService {}
