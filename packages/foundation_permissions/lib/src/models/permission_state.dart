enum PermissionStatusState {
  granted,
  denied,
  permanentlyDenied,
}

class PermissionState {
  final PermissionStatusState status;
  const PermissionState(this.status);

  bool get isGranted => status == PermissionStatusState.granted;
}