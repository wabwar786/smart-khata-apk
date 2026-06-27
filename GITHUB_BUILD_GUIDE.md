# GitHub APK Build Guide

## 1. Upload files

Upload this project to GitHub. These files must be in repository root:

```text
pubspec.yaml
lib/main.dart
lib/config.dart
.github/workflows/build-apk.yml
```

## 2. Run build

Go to:

```text
GitHub repo → Actions → Build Smart Khata Android APK → Run workflow
```

## 3. Download APK

After successful build, download:

```text
smart-khata-release-apk
```

Inside it:

```text
app-release.apk
```

## 4. Install fresh APK

Uninstall old Smart Khata app first, then install the new APK.

## Why this version is important

The old release APK could show this error:

```text
SocketException: Failed host lookup
```

The common reason is missing Android Internet permission in release build. This workflow adds the permission automatically after `flutter create` generates Android files.
