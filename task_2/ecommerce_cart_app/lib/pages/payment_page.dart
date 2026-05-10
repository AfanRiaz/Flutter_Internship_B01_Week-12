import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
        centerTitle: true,
      ),

      body: Center(
        child: InkWell(
          onTap: () async {
            await makePayment();
          },

          child: Container(
            height: 50,
            width: 250,

            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Center(
              child: Text(
                'Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// MAKE PAYMENT
  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent(
        '20',
        'USD',
      );

      if (paymentIntentData == null) {
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters:
        SetupPaymentSheetParameters(
          paymentIntentClientSecret:
          paymentIntentData!['client_secret'],

          merchantDisplayName: 'Afan',

          googlePay:
          const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );

      await displayPaymentSheet();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// DISPLAY PAYMENT SHEET
  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      setState(() {
        paymentIntentData = null;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment Successful',
            ),
          ),
        );
      }

    } on StripeException catch (e) {

      debugPrint(e.toString());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment Cancelled',
            ),
          ),
        );
      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// CREATE PAYMENT INTENT
  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount,
      String currency,
      ) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse(
          'https://api.stripe.com/v1/payment_intents',
        ),

        body: body,

        headers: {
          'Authorization':
          'Bearer YOUR_SECRET_KEY',

          'Content-Type':
          'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);

    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// CALCULATE AMOUNT
  String calculateAmount(String amount) {
    final price =
        int.parse(amount) * 100;

    return price.toString();
  }
}