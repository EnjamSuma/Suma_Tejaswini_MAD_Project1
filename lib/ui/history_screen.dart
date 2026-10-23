import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/dates.dart';
import '../core/money.dart';
import '../data/models.dart';
import '../state/meals_notifier.dart';
import '../state/purchases_notifier.dart';
import '../state/settings_notifier.dart';
import 'widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _cuisine = 'All';

  Future<void> _editPrice(PurchaseLog p) async {
    final c = TextEditingController(
        text: formatMinor(p.actualPriceMinor).substring(1));
    final minor = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit price'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Price (\$)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                final m = parseToMinor(c.text);
                if (m != null) Navigator.pop(context, m);
              },
              child: const Text('Save')),
        ],
      ),
    );
    if (minor == null || !mounted) return;
    await context.read<PurchasesNotifier>().update(PurchaseLog(
        id: p.id, mealId: p.mealId, purchasedAt: p.purchasedAt,
        actualPriceMinor: minor, note: p.note, status: p.status,
        saveKey: p.saveKey));
  }

  Future<void> _delete(PurchaseLog p) async {
    final notifier = context.read<PurchasesNotifier>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete purchase?'),
        content: Text('Delete the ${formatMinor(p.actualPriceMinor)} purchase?'),
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
    if (ok == true) await notifier.remove(p.id!);
  }

  @override
  Widget build(BuildContext context) {
    final purchases = context.watch<PurchasesNotifier>();
    final meals = context.watch<MealsNotifier>();
    final budget = context.watch<SettingsNotifier>().budgetMinor;
    final byId = {for (final m in meals.all) m.id: m};

    final shown = purchases.logs.where((p) =>
        _cuisine == 'All' || byId[p.mealId]?.cuisine == _cuisine).toList();
    final total = shown.fold<int>(0, (s, p) => s + p.actualPriceMinor);
    final used = budget == 0 ? 0 : (total * 100 ~/ budget);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: purchases.period,
                items: [for (final p in periods)
                  DropdownMenuItem(value: p, child: Text(p))],
                onChanged: (v) => purchases.setPeriod(v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _cuisine,
                items: [for (final c in ['All', ...cuisines])
                  DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => _cuisine = v!),
              ),
            ),
          ]),
        ),
        Card(
          child: ListTile(
            title: Text(shown.isEmpty
                ? 'No purchases yet'
                : 'Total ${formatMinor(total)}  |  ${shown.length} purchases'),
            subtitle: shown.isEmpty
                ? null
                : Text('Average ${formatMinor(total ~/ shown.length)}  |  '
                    '$used% of weekly budget'),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? const EmptyState('No purchases match these filters.')
              : ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (_, i) {
                    final p = shown[i];
                    return ListTile(
                      onTap: () => _editPrice(p),
                      title: Text(
                          '${byId[p.mealId]?.name ?? 'Meal'}  ${formatMinor(p.actualPriceMinor)}'),
                      subtitle: Text(p.purchasedAt),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(p)),
                    );
                  }),
        ),
      ]),
    );
  }
}