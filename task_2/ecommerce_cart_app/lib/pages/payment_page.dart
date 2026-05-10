import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../providers/cart_provider.dart';
import 'confirmation_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() =>
      _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  String selectedPayment = 'Cash on Delivery';

  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {

    final provider =
    Provider.of<CartProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// CASH ON DELIVERY
            RadioListTile(
              title: const Text(
                'Cash on Delivery',
              ),

              value: 'Cash on Delivery',

              groupValue: selectedPayment,

              onChanged: (value) {

                setState(() {
                  selectedPayment = value!;
                });
              },
            ),

            /// CREDIT CARD
            RadioListTile(
              title: const Text(
                'Credit Card',
              ),

              value: 'Credit Card',

              groupValue: selectedPayment,

              onChanged: (value) async {

                setState(() {
                  selectedPayment = value!;
                });

                await makePayment();

                if (context.mounted) {

                  provider.savePaymentMethod(
                    selectedPayment,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const ConfirmationPage(),
                    ),
                  );
                }
              },
            ),

            /// STRIPE
            RadioListTile(
              title: const Text('Stripe'),

              value: 'Stripe',

              groupValue: selectedPayment,

              onChanged: (value) {

                setState(() {
                  selectedPayment = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                  provider.savePaymentMethod(
                    selectedPayment,
                  );

                  /// If Cash On Delivery
                  if (selectedPayment ==
                      'Cash on Delivery') {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const ConfirmationPage(),
                      ),
                    );
                  }

                  /// If Stripe
                  else {

                    await makePayment();

                    if (context.mounted) {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ConfirmationPage(),
                        ),
                      );
                    }
                  }
                },

                child: const Text(
                  'Continue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MAKE PAYMENT
  Future<void> makePayment() async {

    try {

      paymentIntentData =
      await createPaymentIntent(
        '20',
        'USD',
      );

      await Stripe.instance.initPaymentSheet(

        paymentSheetParameters:
        SetupPaymentSheetParameters(

          paymentIntentClientSecret:
          paymentIntentData![
          'client_secret'
          ],

          googlePay:
          const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),

          merchantDisplayName: 'Afan',
        ),
      );

      await displayPaymentSheet();

    } catch (e) {

      print(e.toString());
    }
  }

  /// DISPLAY PAYMENT SHEET
  Future<void> displayPaymentSheet() async {

    try {

      await Stripe.instance
          .presentPaymentSheet();

      setState(() {
        paymentIntentData = null;
      });

      if (context.mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Payment Successful',
            ),
          ),
        );
      }

    } on StripeException catch (e) {

      print(e);

      if (context.mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              'Payment Cancelled',
            ),
          ),
        );
      }

    } catch (e) {

      print(e.toString());
    }
  }

  /// CREATE PAYMENT INTENT
  Future<dynamic> createPaymentIntent(
      String amount,
      String currency,
      ) async {

    try {

      Map<String, dynamic> body = {

        'amount':
        calculatAmount(amount),

        'currency':
        currency,

        'payment_method_types[]':
        'card',
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

      return jsonDecode(
        response.body.toString(),
      );

    } catch (e) {

      print(e.toString());
    }
  }

  /// CALCULATE AMOUNT
  String calculatAmount(String amount) {

    final price =
        int.parse(amount) * 100;

    return price.toString();
  }
}