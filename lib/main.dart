import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:threadly/core/common/error_text.dart';
import 'package:threadly/core/common/loader.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/firebase_options.dart';
import 'package:threadly/router.dart';
import 'package:threadly/theme/pallete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authStateChangeProvider).when(
      data: (data) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Threadly',
        theme: AppPallete.darkModeAppTheme,
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          if (data != null) {
            return loggedInRoute;
          } else {
            return loggedOutRoute;
          }
        }),
        routeInformationParser: const RoutemasterParser(),
      ),
      error: (error, stackTrace) => ErrorText(error: error.toString()),
      loading: () => const Loader(),
    );
  }
}
