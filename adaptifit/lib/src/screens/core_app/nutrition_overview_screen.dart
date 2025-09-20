import 'package:flutter/material.dart';

class NutritionOverviewScreen extends StatelessWidget {
  final String nutritionId;

  const NutritionOverviewScreen({Key? key, required this.nutritionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Overview'),
      ),
      body: Center(
        child: Text('Nutrition Overview for nutrition ID: $nutritionId'),
      ),
    );
  }
}
