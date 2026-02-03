import 'package:protobuf/protobuf.dart' show GeneratedMessage;
import '../../reja/v1/forms.pb.dart';
import '../../../google/protobuf/timestamp.pb.dart';
import 'auth.pbenum.dart';

class OrganizationSummary {
  String id = '';
  String slug = '';
  String name = '';
  String logoUrl = '';
  String role = '';
}

class UserSummary {
  String id = '';
  String email = '';
}

class LoginRequest {
  String email = '';
  String password = '';
  String appId = '';
  String orgSlug = '';
}

class SelectOrganizationRequest {
  String orgSelectionToken = '';
  String orgSlug = '';
  String appId = '';
}

class SwitchOrganizationRequest {
  String orgSlug = '';
  String appId = '';
}

class LogoutRequest {
  String refreshToken = '';
}

class RefreshTokenRequest {
  String refreshToken = '';
}

class RefreshTokenResponse {
  String accessToken = '';
  String refreshToken = '';
  Timestamp accessTokenExpiresAt = Timestamp();
  Timestamp refreshTokenExpiresAt = Timestamp();
}

class LoginResponse {
  bool requiresOrgSelection = false;
  bool requiresMfa = false;
  String orgSelectionToken = '';
  String mfaToken = '';
  List<String> mfaMethods = [];
  List<OrganizationSummary> organizations = [];
  UserSummary user = UserSummary();
  OrganizationSummary organization = OrganizationSummary();
  List<String> features = [];
  String role = '';
  String accessToken = '';
  String refreshToken = '';
  Timestamp accessTokenExpiresAt = Timestamp();
  Timestamp refreshTokenExpiresAt = Timestamp();
}
