# foundation_storage

Secure storage + prefs + Drift DB + file cache, with scoped storage helpers.

## Initialize
```dart
await StorageInitializer.initialize(
  options: const StorageOptions(
    dbName: 'foundation.db',
    encryptionEnabled: true,
    cacheDirName: 'foundation_cache',
  ),
);
```
Access singletons:
```dart
final db = StorageInitializer.database;
final secure = StorageInitializer.secureStorage;
final prefs = StorageInitializer.preferencesStorage;
final files = StorageInitializer.fileStorage;
```

## What to store where
- SecureStorage: tokens, secrets
- PreferencesStorage: lightweight user prefs (theme/locale)
- Drift DB: structured/cache data
- File cache: large blobs/images (optionally encrypted)

## Cache sizing
```dart
final size = await StorageInitializer.getCacheSize();
print(size.totalBytes); // db + file cache
print(size.formatted);  // human friendly
```

## Logout handling
- By default `StorageOptions.clearOnLogout = true`; `StorageInitializer.clearAll()` wipes scoped data.
- Disable by setting `clearOnLogout: false` and handle cleanup yourself.

## Testing helpers
- `StorageOptions.dbPathOverride` and `cacheDirOverride` let you target temp dirs.
- `StorageInitializer.reset()` clears static singletons between tests.
