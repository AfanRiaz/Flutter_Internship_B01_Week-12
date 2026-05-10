import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'pages/cart_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
  'pk_test_51TU5pMCMsoXe9YtNxVqnTh4jXK7j9pv4zOzFYtfgMP6JiHqvHrB88WgOOBWtO8yZynhxmqqzoWFJIU6me0JblBQR00qJtjCWKv';


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const CartPage(),
      ),
    );
  }
}
