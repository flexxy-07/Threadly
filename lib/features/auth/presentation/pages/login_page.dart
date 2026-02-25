import 'package:flutter/material.dart';
import 'package:threadly/theme/pallete.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.blackColor,
        centerTitle: true,
        leadingWidth: 120,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Threadly',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        title: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Image.asset(
            'lib/core/images/logo/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 30,
                width: 30,
                color: Colors.grey,
                child: const Center(child: Text('Logo')),
              );
            },
          ),
        ),
        actions: [
          Row(
            children: [TextButton(child: const Text('Skip'), onPressed: () {})],
          ),
        ],
      ),
      body: Center(child: Text('Login Page')),
    );
  }
}
