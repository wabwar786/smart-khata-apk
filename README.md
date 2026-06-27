# Smart Khata Flutter App - Enhanced MVP

This is the enhanced Android MVP for Smart Khata. It is connected to:

https://smart-khata-production.up.railway.app

## Included modules

- Login/signup with fixed login business selection
- Professional dashboard UI
- Dashboard KPI cards
- Sales trend chart
- Customers list/add/detail
- Customer ledger/khata screen
- Products/services list/add
- Sales invoice list/create
- Receive payment module
- Payments list
- Reminders list/add
- Subscription status screen
- More modules screen
- GitHub Actions online APK build
- Android internet permission auto-fix in build workflow

## Build online with GitHub Actions

1. Upload all files to GitHub repo root.
2. Go to Actions.
3. Run **Build Smart Khata Android APK**.
4. Download the artifact `smart-khata-release-apk`.
5. Uninstall old APK from phone.
6. Install the new APK.

## API base URL

`lib/config.dart`

```dart
class AppConfig {
  static const String appName = 'Smart Khata';
  static const String apiBaseUrl = 'https://smart-khata-production.up.railway.app';
}
```

Do not add `/api/auth/login` in the base URL.
