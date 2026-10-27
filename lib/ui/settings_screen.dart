import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/money.dart';
import '../data/csv_export.dart';
import '../data/meal_repository.dart';
import '../data/purchase_repository.dart';
import '../services/reminder_service.dart';
import '../state/settings_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _dollars;
  late bool _reminder;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsNotifier>();
    _dollars = s.budgetMinor / 100;
    _reminder = s.reminderOn;
  }

  Future<void> _toggleReminder(bool on) async {
    final settings = context.read<SettingsNotifier>();
    final messenger = ScaffoldMessenger.of(context);
    if (on) {
      final granted = await ReminderService.instance.enableDaily();
      if (!granted) {
        messenger.showSnackBar(const SnackBar(
            content: Text('Notification permission was denied. '
                'Turn it on in your phone settings to use reminders.')));
        return;
      }
    } else {
      await ReminderService.instance.disable();
    }
    await settings.setReminder(on);
    if (!mounted) return;
    setState(() => _reminder = on);
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final meals = context.read<MealRepository>();
    final buys = context.read<PurchaseRepository>();
    try {
      final path = await exportPurchasesCsv(meals, buys);
      messenger.showSnackBar(SnackBar(content: Text('Saved to $path')));
    } catch (e) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not export. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text('Weekly budget: ${formatMinor(_dollars.round() * 100)}',
              style: Theme.of(context).textTheme.titleMedium),
          Slider(
            min: 10,
            max: 300,
            divisions: 29,
            value: _dollars.clamp(10, 300),
            label: formatMinor(_dollars.round() * 100),
            onChanged: (v) => setState(() => _dollars = v),
            onChangeEnd: (v) =>
                context.read<SettingsNotifier>().setBudget(v.round() * 100),
          ),
          SwitchListTile(
            title: const Text('Daily planning reminder'),
            subtitle: const Text('Repeats every day after you turn it on'),
            value: _reminder,
            onChanged: _toggleReminder,
          ),
          OutlinedButton(
              onPressed: ReminderService.instance.showNow,
              child: const Text('Send a test reminder now')),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: _export,
              child: const Text('Export purchases (CSV)')),
        ]),
      );
}