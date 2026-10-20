import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _budget = 75;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text('Weekly budget: \$${_budget.round()}',
              style: Theme.of(context).textTheme.titleMedium),
          Slider(
            min: 10,
            max: 300,
            divisions: 29,
            value: _budget,
            label: '\$${_budget.round()}',
            onChanged: (v) => setState(() => _budget = v),
          ),
        ]),
      );
}