# Smart Khata Flutter App

This package builds the Smart Khata Android APK online using GitHub Actions. No local Flutter installation is required.

API URL:

```text
https://smart-khata-production.up.railway.app
```

## Important Android fix

This version patches `android/app/src/main/AndroidManifest.xml` during the GitHub Actions build and adds:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

This is required for the release APK to call the Railway API.

## Build APK online

1. Upload all files to GitHub repository root.
2. Go to GitHub → Actions.
3. Run `Build Smart Khata Android APK`.
4. Download artifact `smart-khata-release-apk`.
5. Uninstall old APK from phone.
6. Install the new APK.
