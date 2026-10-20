import 'package:flutter/material.dart';
import '../data/models.dart';
import 'meal_detail_screen.dart';
import 'meal_editor_screen.dart';
import 'widgets.dart';

class MealCatalogScreen extends StatefulWidget {
  const MealCatalogScreen({super.key});
  @override
  State<MealCatalogScreen> createState() => _MealCatalogScreenState();
}

class _MealCatalogScreenState extends State<MealCatalogScreen> {
  // TEMPORARY sample data (clearly fictional); replaced by the repository later.
  final List<Meal> _meals = [
    const Meal(id: 1, name: 'Chicken Bowl', venueNote: 'Campus Cafe',
        cuisine: 'Asian', estimatedPriceMinor: 750),
    const Meal(id: 2, name: 'Veggie Wrap', venueNote: 'Food court',
        cuisine: 'American', estimatedPriceMinor: 500),
    const Meal(id: 3, name: 'Bean Burrito', venueNote: 'Dining hall',
        cuisine: 'Mexican', estimatedPriceMinor: 325),
  ];
  String _filter = 'All';

  Future<void> _openEditor([Meal? meal]) async {
    final result = await Navigator.push<Meal>(context,
        MaterialPageRoute(builder: (_) => MealEditorScreen(meal: meal)));
    if (result == null) return;
    setState(() {
      if (meal == null) {
        _meals.add(Meal(
            id: DateTime.now().millisecondsSinceEpoch,
            name: result.name, venueNote: result.venueNote,
            cuisine: result.cuisine,
            estimatedPriceMinor: result.estimatedPriceMinor));
      } else {
        final i = _meals.indexWhere((m) => m.id == meal.id);
        _meals[i] = result;
      }
    });
  }

  Future<void> _confirmDelete(Meal meal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete meal?'),
        // Later: show the real count from MealRepository.countLogs
        content: Text('Delete "${meal.name}" and its purchases?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) setState(() => _meals.removeWhere((m) => m.id == meal.id));
  }

  @override
  Widget build(BuildContext context) {
    final shown = _filter == 'All'
        ? _meals
        : _meals.where((m) => m.cuisine == _filter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Bites')),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(), child: const Icon(Icons.add)),
      body: Column(children: [
        const SummaryCard(spentMinor: 4250, budgetMinor: 7500), // placeholder
        Wrap(spacing: 8, children: [
          for (final c in ['All', ...cuisines])
            ChoiceChip(
                label: Text(c),
                selected: _filter == c,
                onSelected: (_) => setState(() => _filter = c)),
        ]),
        Expanded(
          child: shown.isEmpty
              ? const EmptyState('No meals match this filter. Tap + to add one.')
              : ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (_, i) {
                    final m = shown[i];
                    return MealCard(
                      meal: m,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => MealDetailScreen(meal: m))),
                      onEdit: () => _openEditor(m),
                      onDelete: () => _confirmDelete(m),
                    );
                  }),
        ),
      ]),
    );
  }
}