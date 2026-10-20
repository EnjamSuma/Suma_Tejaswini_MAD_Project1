import 'package:flutter/material.dart';
import '../core/money.dart';
import '../data/models.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(meal.name)),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text('${meal.cuisine}  |  ${meal.venueNote}'),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Receipt'),
              subtitle: Text(
                  'Planned: ${formatMinor(meal.estimatedPriceMinor)}\n'
                  'Actual and difference: coming Oct 23'),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Lunch Lens'),
              subtitle: Text('Not enough history'),
            ),
          ),
        ]),
      );
}