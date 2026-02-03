# foundation_auth

Auth state machine + token/session management for Marulla SSO.

## What this package provides
- A Riverpod-driven auth controller (`authControllerProvider`)
- A deterministic auth state machine:
  - unauthenticated → (org selection?) → (mfa?) → authenticated
- Token persistence via `foundation_storage`
- gRPC-first API adapter using your generated Dart protos (`marulla_protos`)

## How to wire it in your app
1) Add your protos dependency in the app (or melos workspace overrides), e.g.

```yaml
dependencies:
  marulla_protos:
    git:
      url: https://github.com/emuthianimbithi/protos
      path: gen/dart
```

2) Provide `AppConfig` (from `foundation_config`) and `GrpcConfig` so the auth API knows where to connect.

3) Listen to `authStateProvider` and route accordingly.

## Notes
- MFA verification RPC is not included in the snippet you shared; `verifyMfa(...)` is left as a placeholder to wire once the proto is available.
