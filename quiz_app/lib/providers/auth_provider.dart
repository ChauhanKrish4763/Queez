import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_provider.g.dart';

/// App State model for authentication and navigation
class AppState {
  final bool isLoading;
  final bool loggedIn;
  final bool profileSetupCompleted;
  final String lastRoute;

  AppState({
    required this.isLoading,
    required this.loggedIn,
    required this.profileSetupCompleted,
    required this.lastRoute,
  });

  AppState copyWith({
    bool? isLoading,
    bool? loggedIn,
    bool? profileSetupCompleted,
    String? lastRoute,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      loggedIn: loggedIn ?? this.loggedIn,
      profileSetupCompleted:
          profileSetupCompleted ?? this.profileSetupCompleted,
      lastRoute: lastRoute ?? this.lastRoute,
    );
  }

  factory AppState.initial() {
    return AppState(
      isLoading: true,
      loggedIn: false,
      profileSetupCompleted: false,
      lastRoute: '/login',
    );
  }
}

/// Provider for SharedPreferences instance
@riverpod
Future<SharedPreferences> sharedPreferences(ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider for app authentication state
@riverpod
class AppAuth extends _$AppAuth {
  @override
  Future<AppState> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final loggedIn = prefs.getBool('loggedIn') ?? false;
    final lastRoute = prefs.getString('lastRoute') ?? '/login';
    final profileSetupCompleted =
        prefs.getBool('profileSetupCompleted') ?? false;

    String navigationRoute = '/login';
    if (loggedIn && !profileSetupCompleted) {
      navigationRoute = '/profile_welcome';
    } else if (loggedIn) {
      navigationRoute = lastRoute;
    }

    return AppState(
      isLoading: false,
      loggedIn: loggedIn,
      profileSetupCompleted: profileSetupCompleted,
      lastRoute: navigationRoute,
    );
  }

  /// Login user
  Future<void> login({bool? profileCompleted, String? lastRoute}) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('loggedIn', true);

    if (profileCompleted != null) {
      await prefs.setBool('profileSetupCompleted', profileCompleted);
    }

    if (lastRoute != null) {
      await prefs.setString('lastRoute', lastRoute);
    } else {
      await prefs.setString('lastRoute', '/dashboard');
    }

    ref.invalidateSelf();
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('loggedIn', false);
    await prefs.setString('lastRoute', '/login');
    ref.invalidateSelf();
  }

  /// Mark profile setup as completed
  Future<void> completeProfileSetup() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('profileSetupCompleted', true);
    ref.invalidateSelf();
  }

  /// Update last route
  Future<void> updateLastRoute(String route) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('lastRoute', route);
    ref.invalidateSelf();
  }
}
