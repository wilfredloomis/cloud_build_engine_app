# Cloud Build Engine App

Flutter mobile app for the Cloud APK Build Engine. Upload source ZIP projects and build APKs in the cloud using GitHub Actions.

## Features

- **Upload** source project ZIP files (Flutter, React Native, Expo, Native Android)
- **Build** APKs in the cloud via GitHub Actions
- **Monitor** build progress with real-time step tracking
- **Download** built APK artifacts
- **Share** or install APKs directly from the app
- **History** of all builds with status tracking

## Architecture

```
Flutter App → Cloudflare Worker API → GitHub Actions → APK Artifact → Flutter App
```

## Screens

| Screen | Description |
|--------|-------------|
| Splash | App launch animation |
| Home | Build history with counters (Total/Running/Success/Failed) |
| New Build | ZIP picker, build config, start build |
| Build Details | Real-time status, step progress, download button |
| Build Logs | View build step details |
| Result | APK ready — install or share |
| Settings | API URL config, about, clear history |

## Project Structure

```
lib/
  main.dart
  app/
    app.dart          # MultiProvider + MaterialApp
    routes.dart       # Named routes
    theme.dart        # Dark theme
    constants.dart    # API URLs, status strings, limits
  models/
    build_job.dart
    build_step_item.dart
    prepare_upload_response.dart
    dispatch_response.dart
    build_status_response.dart
    artifact_response.dart
  services/
    api_service.dart          # HTTP client for Worker API
    upload_service.dart       # Upload with progress
    artifact_service.dart     # Download + extract APK from ZIP
    local_storage_service.dart # SharedPreferences persistence
    file_picker_service.dart  # ZIP file picker
    zip_extract_service.dart  # ZIP inspection + project detection
  controllers/
    home_controller.dart         # Build history + counters
    new_build_controller.dart    # Upload + dispatch flow
    build_details_controller.dart # Polling + download
  widgets/
    build_card.dart
    build_counter_card.dart
    build_step_tile.dart
    upload_box.dart
    progress_button.dart
    status_badge.dart
    glass_card.dart
  screens/
    splash_screen.dart
    home_screen.dart
    new_build_screen.dart
    build_details_screen.dart
    build_logs_screen.dart
    result_screen.dart
    settings_screen.dart
```

## Setup

1. Clone this repo
2. Run `flutter pub get`
3. Set your Worker API URL in Settings (or update `AppConstants.apiBaseUrl`)
4. Run `flutter run`

## Backend

This app requires the [cloud-workflow-engine](https://github.com/wilfredloomis/cloud-workflow-engine) backend (Cloudflare Worker + GitHub Actions).
