import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/money.dart';
import '../state/settings_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _dollars;

  @override
  void initState() {
    super.initState();
    _dollars = context.read<SettingsNotifier>().budgetMinor / 100;
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
        ]),
      );
}