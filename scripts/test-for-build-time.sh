BUILD_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
flutter run -d macos --dart-define=BUILD_TIME=$BUILD_TIME
