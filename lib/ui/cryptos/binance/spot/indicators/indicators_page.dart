import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'indicators_controller.dart';

class IndicatorsPage extends GetView<IndicatorsController> {
  const IndicatorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicators'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Indicators View'),
      ),
    );
  }
}
