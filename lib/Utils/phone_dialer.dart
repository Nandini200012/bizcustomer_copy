// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneDialer {
  static Future<void> makeCall(BuildContext context, String phoneNumber) async {
    // Remove any non-digit characters except '+' for international numbers
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    log('phone number : $phoneNumber , cleaned $cleanedNumber');
    // final url = 'tel:9162385959';
    // cleanedNumber';
    final url = Uri(
      scheme: 'tel',
      path: '6238518989',
    );
    try {
      if (await canLaunch(url.toString())) {
        await launch(url.toString());
      } else {
        _showNoDialerDialog(context);
      }
    } catch (e) {
      _showErrorSnackbar(context, "Failed to make call: ${e.toString()}");
    }
  }

  static void _showNoDialerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Dialer App Found"),
        content:
            const Text("Your device doesn't have a phone dialer app installed. "
                "Please install one from the Play Store to make calls."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class PhoneDialer {
//   static const MethodChannel _channel = MethodChannel('phone_dialer');

//   static Future<void> makeCall(BuildContext context, String phoneNumber) async {
//     try {
//       await _channel.invokeMethod('makeCall', {'phoneNumber': phoneNumber});
//     } on PlatformException catch (e) {
//       _showErrorSnackbar(context, e.message ?? "Failed to make a call");
//     }
//   }

//   static void _showErrorSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }
// }
