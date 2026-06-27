# GitHub Online APK Build Guide

No Flutter installation is required on your Windows PC.

## Steps

1. Create GitHub repo: `smart-khata-flutter-app`
2. Upload all files from this folder into repo root.
3. Open repo > Actions.
4. Select `Build Smart Khata Android APK`.
5. Click `Run workflow`.
6. Wait until build completes.
7. Download artifact `smart-khata-release-apk`.
8. Install `app-release.apk` on Android phone.

## Important

Before installing new APK, uninstall old Smart Khata APK from phone.

## If login gives network error

Open this on the same phone browser:

https://smart-khata-production.up.railway.app/health

Expected:

```json
{"status":"ok"}
```
