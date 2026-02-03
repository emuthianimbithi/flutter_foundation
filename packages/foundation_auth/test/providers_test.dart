import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_networking/foundation_networking.dart';
import 'package:foundation_storage/foundation_storage.dart';
import 'package:grpc/grpc.dart';

class _FakeChannelFactory extends GrpcChannelFactory {
  _FakeChannelFactory()
      : super(
            config: const GrpcConfig(
                host: 'localhost', port: 50051, useTls: false));

  @override
  ClientChannel getChannel() => throw GrpcError.unimplemented('fake');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final appConfig =
      AppConfig(environment: Environment.development, appId: 'test');

  ProviderContainer _containerWithOverrides() {
    return ProviderContainer(overrides: [
      appConfigProvider.overrideWithValue(appConfig),
      secureStorageProvider.overrideWithValue(SecureStorage()),
      preferencesStorageProvider.overrideWithValue(PreferencesStorage()),
      grpcChannelFactoryProvider.overrideWithValue(_FakeChannelFactory()),
    ]);
  }

  test('providers do not throw after overrides', () {
    final container = _containerWithOverrides();
    expect(container.read(appConfigProvider), equals(appConfig));
    expect(() => container.read(secureStorageProvider), returnsNormally);
    expect(() => container.read(preferencesStorageProvider), returnsNormally);
    expect(() => container.read(grpcChannelFactoryProvider), returnsNormally);
  });
}
