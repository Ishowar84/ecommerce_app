import 'package:flutter/material.dart';
import 'package:ecommerse_website/models/user.dart';
import 'package:ecommerse_website/pages/home_page.dart';
import 'package:ecommerse_website/pages/login_page.dart';
import 'package:ecommerse_website/themes/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/user-selection',
      routes: {
        '/user-selection': (context) =>  UserSelectionPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as User;
          return HomePage(loggedInUser: args);
        },
      },
    );
  }
}
