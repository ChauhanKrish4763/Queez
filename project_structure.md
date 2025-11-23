# Project Structure

## Quiz App (quiz_app/)

```
quiz_app/
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── analyze_output.txt
├── devtools_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── TODO.txt
├── .vscode/
│   └── settings.json
├── lib/
│   ├── api_config.dart
├── main.dart
│   ├── config/
│   ├── CreateSection/
│   │   ├── mixins/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── LibrarySection/
│   │   ├── LiveMode/
│   │   ├── PlaySection/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── models/
│   │   ├── multiplayer_models.dart
│   │   ├── multiplayer_models.freezed.dart
│   │   ├── multiplayer_models.g.dart
│   │   └── user_model.dart
│   ├── ProfilePage/
│   │   └── profile_page.dart
│   ├── ProfileSetup/
│   │   ├── profile_setup_routes.dart
│   │   ├── screens/
│   │   └── widgets/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── auth_provider.g.dart
│   │   ├── game_provider.dart
│   │   ├── leaderboard_provider.dart
│   │   ├── library_provider.dart
│   │   ├── library_provider.g.dart
│   │   ├── navigation_provider.dart
│   │   ├── navigation_provider.g.dart
│   │   └── session_provider.dart
│   ├── screens/
│   │   ├── dashboard.dart
│   │   └── login_page.dart
│   ├── services/
│   │   └── websocket_service.dart
│   ├── utils/
│   │   ├── animations/
│   │   ├── color.dart
│   │   ├── custom_navigator.dart
│   │   ├── globals.dart
│   │   ├── quiz_design_system.dart
│   │   └── routes.dart
│   └── widgets/
│       ├── appbar/
│       ├── leaderboard_widget.dart
│       ├── navbar/
│       └── reconnection_overlay.dart
├── assets/
│   ├── icons/
│   └── ui/
├── android/
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── local.properties
│   ├── settings.gradle.kts
│   └── app/
│       ├── build.gradle.kts
│       ├── google-services.json
│       └── src/
├── web/
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── windows/
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
├── linux/
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
├── macos/
│   ├── Flutter/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
└── test/
    └── widget_test.dart
```

## Backend (Queez-Backend/)

```
Queez-Backend/
├── .env.example
├── .gitignore
├── Dockerfile
├── render.yaml
├── requirements.txt
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── api/
│   │   ├── __init__.py
│   │   └── routes/
│   │       ├── __init__.py
│   │       ├── analytics.py
│   │       ├── categories.py
│   │       ├── flashcards.py
│   │       ├── leaderboard.py
│   │       ├── library.py
│   │       ├── live_multiplayer.py
│   │       ├── quizzes.py
│   │       ├── results.py
│   │       ├── reviews.py
│   │       ├── sessions.py
│   │       ├── users.py
│   │       ├── websocket.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py
│   │   ├── database.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── flashcard.py
│   │   ├── quiz.py
│   │   ├── session.py
│   ├── services/
│   │   ├── connection_manager.py
│   │   ├── game_controller.py
│   │   ├── leaderboard_manager.py
│   │   ├── session_manager.py
│   │   ├── websocket_manager.py
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
└── image/
    └── API_TESTING_REPORT/
```