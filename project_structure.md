# Project Structure

## Quiz App (quiz_app/)

```
quiz_app/
├── pubspec.yaml
├── lib/
│   ├── main.dart
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
│       └── sci-fi/
├── android/
│   └── app/
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

## Backend (backend/)

```
backend/
├── main.py
├── requirements.txt
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── api/
│   │   ├── __init__.py
│   │   └── routes/
│   │       ├── analytics.py
│   │       ├── categories.py
│   │       ├── leaderboard.py
│   │       ├── live_multiplayer.py
│   │       ├── quizzes.py
│   │       ├── results.py
│   │       ├── reviews.py
│   │       ├── sessions.py
│   │       ├── users.py
│   │       ├── websocket.py
│   │       └── __init__.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py
│   │   ├── database.py
│   │   └── redis_client.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── quiz.py
│   │   └── session.py
│   ├── services/
│   │   ├── connection_manager.py
│   │   ├── game_controller.py
│   │   ├── leaderboard_manager.py
│   │   ├── session_manager.py
│   │   └── websocket_manager.py
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
└── tests/
    ├── test_comprehensive.py
    └── test_multiplayer.py
```