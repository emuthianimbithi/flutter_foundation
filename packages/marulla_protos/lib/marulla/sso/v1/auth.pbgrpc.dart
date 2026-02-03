import 'package:grpc/grpc.dart';
import 'auth.pb.dart';

class AuthServiceClient {
  final ClientChannel channel;
  final CallOptions? options;
  AuthServiceClient(this.channel, {this.options});

  Future<LoginResponse> login(LoginRequest request, {CallOptions? options}) async {
    throw UnimplementedError();
  }

  Future<LoginResponse> selectOrganization(SelectOrganizationRequest request, {CallOptions? options}) async {
    throw UnimplementedError();
  }

  Future<LoginResponse> switchOrganization(SwitchOrganizationRequest request, {CallOptions? options}) async {
    throw UnimplementedError();
  }

  Future<void> logout(LogoutRequest request, {CallOptions? options}) async {
    return;
  }

  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request, {CallOptions? options}) async {
    throw UnimplementedError();
  }
}
