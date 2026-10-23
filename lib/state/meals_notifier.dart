import 'package:flutter/foundation.dart';
import '../data/meal_repository.dart';
import '../data/models.dart';

class MealsNotifier extends ChangeNotifier {
  final MealRepository _repo;
  MealsNotifier(this._repo);

  List<Meal> all = [];
  String cuisine = 'All';
  bool loading = true;
  String? error;

  List<Meal> get visible =>
      cuisine == 'All' ? all : all.where((m) => m.cuisine == cuisine).toList();

  Future<void> load() async {
    try {
      all = await _repo.getAll();
      error = null;
    } catch (e) {
      error = 'Could not load meals. Please try again.';
    }
    loading = false;
    notifyListeners();
  }

  void setCuisine(String c) {
    cuisine = c;
    notifyListeners();
  }

  Future<void> save(Meal m) async {
    if (m.id == null) {
      await _repo.insert(m);
    } else {
      await _repo.update(m);
    }
    await load();
  }

  Future<int> logCount(int mealId) => _repo.countLogs(mealId);

  Future<void> remove(int id) async {
    await _repo.delete(id);
    await load();
  }
}