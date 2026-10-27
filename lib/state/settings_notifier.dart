import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  SettingsNotifier(this._prefs);

  int budgetMinor = 7500; // $75.00 default

  bool reminderOn = false;

  void load() {
    budgetMinor = _prefs.getInt('weekly_budget_minor') ?? 7500;
    reminderOn = _prefs.getBool('reminder_on') ?? false;
    notifyListeners();
  }

  Future<void> setReminder(bool on) async {
    reminderOn = on;
    notifyListeners();
    await _prefs.setBool('reminder_on', on);
  }

  Future<void> setBudget(int minor) async {
    budgetMinor = minor;
    notifyListeners();
    await _prefs.setInt('weekly_budget_minor', minor);
  }
}