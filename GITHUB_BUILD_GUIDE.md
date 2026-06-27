# Build Smart Khata APK Online with GitHub Actions

You do not need to install Flutter on your PC. GitHub Actions will install Flutter online and build the APK for you.

## 1. Upload to GitHub

1. Create a new GitHub repository, for example `smart-khata-flutter-app`.
2. Upload all files from this folder to the repository root.
3. Make sure these files are in the root:

```text
pubspec.yaml
lib/main.dart
.github/workflows/build-apk.yml
```

## 2. Run online build

1. Open your GitHub repository.
2. Go to **Actions**.
3. Select **Build Smart Khata Android APK**.
4. Click **Run workflow**.
5. Wait until the build is complete.

## 3. Download APK

1. Open the completed workflow run.
2. Scroll down to **Artifacts**.
3. Download `smart-khata-release-apk`.
4. Extract it.
5. Install `app-release.apk` on your Android phone.

## 4. API URL

The app is already configured to use:

```text
https://smart-khata-production.up.railway.app
```

This is inside:

```text
lib/config.dart
```

## 5. When you change code

Every time you push code to GitHub, GitHub Actions will automatically build a new APK.
You can also manually run the workflow from the Actions tab.
