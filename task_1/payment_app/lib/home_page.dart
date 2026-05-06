import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
FirebaseFirestore firestore = FirebaseFirestore.instance;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Payment'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          InkWell(
            onTap: () async{
              await makePayment();
            },
            child: Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.green
              ),
              child: Center(
                  child: Text('Pay')
              ),
            ),
          )
        ],

      ),
    );
  }
  Future<void> makePayment() async{
    try{
      paymentIntentData = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),

        merchantDisplayName: 'Afan'
      ));
      displayPaymentSheet();
    }
    catch(e){
      print(e.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      setState(() {
        paymentIntentData = null;
      });

      await firestore
          .collection('data')
          .doc('Transaction completed')
          .set({
        'status': 'success',
        'amount': '20',
        'currency': 'USD',
        'time': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful'),
        ),
      );

    } on StripeException catch (e) {
      print(e);
      await firestore
          .collection('data')
          .doc('Transaction canceled')
          .set({
        'status': 'cancelled',
        'time': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Cancelled'),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> createPaymentIntent(String amount, String currency) async{
    try{
      Map<String, dynamic> body = {
        'amount' : calculatAmount(amount),
        'currency' : currency,
        'payment_method_types[]' : 'card',
      };
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
        'Authorization': 'Bearer sk_test_51TU5pMCMsoXe9YtNiFb8D0buSiCcdLKrqHs2XrNXTgBpEULl3k6StAA8J03LKO1i6FYI1tfMlYdUD4bIoOh7boKx00qMHyR1vf',
          'Content-Type' : 'application/x-www-form-urlencoded'
        }
      );
      return jsonDecode(response.body.toString());
    }
    catch(e){
      print(e.toString());
    }
  }
  calculatAmount(String amount){
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}

