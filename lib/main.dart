import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/meal_repository.dart';
import 'data/purchase_repository.dart';
import 'data/seed.dart';
import 'state/meals_notifier.dart';
import 'state/purchases_notifier.dart';
import 'state/settings_notifier.dart';
import 'ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final mealRepo = MealRepository();
  final purchaseRepo = PurchaseRepository();
  await seedIfEmpty(mealRepo, purchaseRepo);

  runApp(MultiProvider(
    providers: [
      // Repositories are injected here, so tests can swap in fakes.
      Provider<MealRepository>.value(value: mealRepo),
      Provider<PurchaseRepository>.value(value: purchaseRepo),
      ChangeNotifierProvider(create: (_) => SettingsNotifier(prefs)..load()),
      ChangeNotifierProvider(create: (_) => MealsNotifier(mealRepo)..load()),
      ChangeNotifierProvider(
          create: (_) => PurchasesNotifier(purchaseRepo)..load()),
    ],
    child: const BudgetBitesApp(),
  ));
}

class BudgetBitesApp extends StatelessWidget {
  const BudgetBitesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Budget Bites',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const AppShell(),
      );
}