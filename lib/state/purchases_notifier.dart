import 'package:flutter/foundation.dart';
import '../core/dates.dart';
import '../data/models.dart';
import '../data/purchase_repository.dart';

class PurchasesNotifier extends ChangeNotifier {
  final PurchaseRepository _repo;
  PurchasesNotifier(this._repo);

  List<PurchaseLog> logs = [];
  int weekTotalMinor = 0;
  String period = 'This week';
  bool saving = false;
  String? error;

  Future<void> load() async {
    try {
      final now = DateTime.now();
      final r = periodRange(period, now);
      logs = await _repo.inRange(from: r.from, to: r.to);
      final w = periodRange('This week', now);
      weekTotalMinor = await _repo.totalFinal(from: w.from, to: w.to);
      error = null;
    } catch (e) {
      error = 'Could not load purchases. Please try again.';
    }
    notifyListeners();
  }

  Future<void> setPeriod(String p) async {
    period = p;
    await load();
  }

  /// Guard 1: ignore taps while a save is pending.
  /// Guard 2: the unique saveKey makes the database ignore a duplicate.
  Future<bool> add(PurchaseLog p) async {
    if (saving) return false;
    saving = true;
    notifyListeners();
    try {
      await _repo.insert(p);
      error = null;
      await load();
      return true;
    } catch (e) {
      error = 'Could not save. Please try again.';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> update(PurchaseLog p) async {
    await _repo.update(p);
    await load();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    await load();
  }
}