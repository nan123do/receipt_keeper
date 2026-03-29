// lib/pages/home_receipt/views/home_receipt_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/pages/home_receipt/controllers/home_receipt_controller.dart';

class HomeReceiptView extends GetView<HomeReceiptController> {
  const HomeReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('HomeReceiptView'),
      ),
    );
  }
}
