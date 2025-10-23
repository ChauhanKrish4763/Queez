import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Queez',
      debugShowCheckedModeBanner: false,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends ConsumerWidget {
  const AppEntryPoint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appAuthProvider);

    return appState.when(
      data: (state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate after build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            final routeToNavigate =
                state.lastRoute == '/' ? '/login' : state.lastRoute;
            customNavigateReplacement(
              context,
              routeToNavigate,
              AnimationType.fade,
            );
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
