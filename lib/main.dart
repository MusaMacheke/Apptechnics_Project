import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => AuthScreen(),
        '/search': (context) => const SearchScreen(),
      },
      debugShowCheckedModeBanner: false, // Removes the debug banner
    );
  }
}
