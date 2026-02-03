class VerifyMFARequest {
  String mfaToken = '';
  String code = '';
}

class UseRecoveryCodeRequest {
  String mfaToken = '';
  String recoveryCode = '';
}

class SetupTOTPRequest {}

class VerifyTOTPSetupRequest {
  String code = '';
}

class DisableTOTPRequest {
  String password = '';
  String code = '';
}

class GenerateRecoveryCodesRequest {
  String password = '';
}

class GetMFAStatusRequest {}

class SetupTOTPResponse {
  String secret = '';
  String qrCodeUri = '';
  String issuer = '';
  String accountName = '';
}

class VerifyTOTPSetupResponse {
  bool success = true;
  List<String> recoveryCodes = [];
}

class GenerateRecoveryCodesResponse {
  List<String> recoveryCodes = [];
}

class GetMFAStatusResponse {
  bool totpEnabled = false;
  int recoveryCodesRemaining = 0;
  DateTime? totpEnabledAt;
  DateTime? recoveryCodesGeneratedAt;
}
