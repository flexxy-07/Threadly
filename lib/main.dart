import 'package:flutter/material.dart';
import 'package:threadly/features/auth/presentation/pages/login_page.dart';
import 'package:threadly/theme/pallete.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Threadly',
      theme: AppPallete.darkModeAppTheme,
      home: const LoginPage(),
    );
  }
}
