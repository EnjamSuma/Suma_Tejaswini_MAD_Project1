import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../state/meals_notifier.dart';
import '../state/purchases_notifier.dart';
import '../state/settings_notifier.dart';
import 'meal_detail_screen.dart';
import 'meal_editor_screen.dart';
import 'widgets.dart';

class MealCatalogScreen extends StatelessWidget {
  const MealCatalogScreen({super.key});

  Future<void> _openEditor(BuildContext context, [Meal? meal]) async {
    final result = await Navigator.push<Meal>(context,
        MaterialPageRoute(builder: (_) => MealEditorScreen(meal: meal)));
    if (result == null || !context.mounted) return;
    await context.read<MealsNotifier>().save(result);
  }

  Future<void> _confirmDelete(BuildContext context, Meal meal) async {
    final meals = context.read<MealsNotifier>();
    final purchases = context.read<PurchasesNotifier>();
    final count = await meals.logCount(meal.id!);
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete meal?'),
        content: Text(
            'Delete "${meal.name}"? This also deletes $count purchase(s).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await meals.remove(meal.id!);
      await purchases.load(); // cascade removed its purchases
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = context.watch<MealsNotifier>();
    final purchases = context.watch<PurchasesNotifier>();
    final settings = context.watch<SettingsNotifier>();
    final shown = meals.visible;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Bites')),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(context), child: const Icon(Icons.add)),
      body: Column(children: [
        SummaryCard(
            spentMinor: purchases.weekTotalMinor,
            budgetMinor: settings.budgetMinor),
        Wrap(spacing: 8, children: [
          for (final c in ['All', ...cuisines])
            ChoiceChip(
                label: Text(c),
                selected: meals.cuisine == c,
                onSelected: (_) => meals.setCuisine(c)),
        ]),
        Expanded(
          child: meals.error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(meals.error!),
                  TextButton(onPressed: meals.load, child: const Text('Retry')),
                ]))
              : meals.loading
                  ? const Center(child: CircularProgressIndicator())
                  : shown.isEmpty
                      ? const EmptyState(
                          'No meals match this filter. Tap + to add one.')
                      : ListView.builder(
                          itemCount: shown.length,
                          itemBuilder: (_, i) {
                            final m = shown[i];
                            return MealCard(
                              meal: m,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          MealDetailScreen(meal: m))),
                              onEdit: () => _openEditor(context, m),
                              onDelete: () => _confirmDelete(context, m),
                            );
                          }),
        ),
      ]),
    );
  }
}