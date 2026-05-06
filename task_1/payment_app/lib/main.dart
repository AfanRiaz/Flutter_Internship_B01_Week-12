import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:payment_app/home_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51TU5pMCMsoXe9YtNxVqnTh4jXK7j9pv4zOzFYtfgMP6JiHqvHrB88WgOOBWtO8yZynhxmqqzoWFJIU6me0JblBQR00qJtjCWKv';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
    );
  }
}
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

