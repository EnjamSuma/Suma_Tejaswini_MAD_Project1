import 'package:flutter/material.dart';
import '../core/money.dart';
import '../data/models.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const MealCard({super.key, required this.meal, required this.onTap,
      required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          onLongPress: onEdit, // gesture shortcut; menu is the button alternative
          title: Text(meal.name),
          subtitle: Text('${meal.venueNote.isEmpty ? meal.cuisine : meal.venueNote}'
              '  |  Est. ${formatMinor(meal.estimatedPriceMinor)}'),
          trailing: PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      );
}

class SummaryCard extends StatelessWidget {
  final int spentMinor;
  final int budgetMinor;
  const SummaryCard({super.key, required this.spentMinor, required this.budgetMinor});

  @override
  Widget build(BuildContext context) {
    final used = budgetMinor == 0 ? 0.0 : spentMinor / budgetMinor;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('This week: ${formatMinor(spentMinor)} of ${formatMinor(budgetMinor)}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
            tween: Tween<double>(end: used.clamp(0.0, 1.0)),
            duration: MediaQuery.of(context).disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 600),
            builder: (_, v, __) => LinearProgressIndicator(value: v),
          ),
          const SizedBox(height: 8),
          Text('${(used * 100).round()}% of budget used'),
        ]),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState(this.message, {super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      );
}

class ReceiptCard extends StatelessWidget {
  final int plannedMinor;
  final int actualMinor;
  const ReceiptCard(
      {super.key, required this.plannedMinor, required this.actualMinor});

  @override
  Widget build(BuildContext context) {
    final diff = actualMinor - plannedMinor;
    final words = differenceWords(plannedMinor, actualMinor);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Receipt', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Planned: ${formatMinor(plannedMinor)}'),
          Text('Actual: ${formatMinor(actualMinor)}'),
          const SizedBox(height: 4),
          Text('Difference: $words', // words as well as color
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: diff > 0 ? Colors.red.shade700 : Colors.green.shade800)),
        ]),
      ),
    );
  }
}