import 'package:flutter/material.dart';
import 'ui/app_shell.dart';

void main() => runApp(const BudgetBitesApp());

class BudgetBitesApp extends StatelessWidget {
  const BudgetBitesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Budget Bites',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const AppShell(),
      );
}