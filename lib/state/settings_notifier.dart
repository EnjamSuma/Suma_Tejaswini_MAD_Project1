import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  SettingsNotifier(this._prefs);

  int budgetMinor = 7500; // $75.00 default

  void load() {
    budgetMinor = _prefs.getInt('weekly_budget_minor') ?? 7500;
    notifyListeners();
  }

  Future<void> setBudget(int minor) async {
    budgetMinor = minor;
    notifyListeners();
    await _prefs.setInt('weekly_budget_minor', minor);
  }
}