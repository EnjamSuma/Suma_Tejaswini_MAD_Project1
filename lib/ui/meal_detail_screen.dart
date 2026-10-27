import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/dates.dart';
import '../core/money.dart';
import '../data/models.dart';
import '../data/purchase_repository.dart';
import '../domain/lunch_lens.dart';
import '../state/purchases_notifier.dart';
import 'widgets.dart';

class MealDetailScreen extends StatefulWidget {
  final Meal meal;
  const MealDetailScreen({super.key, required this.meal});
  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen>
    with SingleTickerProviderStateMixin {
  List<PurchaseLog> _history = [];
  bool _started = false;
  late int _actual;
  late String _saveKey;
  late final AnimationController _reveal;
  String? _savedNote;

  String get _draftKey => 'draft_${widget.meal.id}';

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _actual = widget.meal.estimatedPriceMinor;
    _saveKey = _newKey();
    _loadHistory();
    _restoreDraft();
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  String _newKey() =>
      '${widget.meal.id}-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _loadHistory() async {
    final repo = context.read<PurchaseRepository>();
    final h = await repo.forMeal(widget.meal.id!);
    if (!mounted) return;
    setState(() => _history = h);
  }

  // The unfinished purchase lives in SharedPreferences until it is saved or reset.
  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || !mounted) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _started = true;
        _actual = d['actual'] as int;
        _saveKey = d['saveKey'] as String;
      });
    } catch (_) {
      await prefs.remove(_draftKey);
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _draftKey, jsonEncode({'actual': _actual, 'saveKey': _saveKey}));
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  void _start() {
    setState(() {
      _started = true;
      _savedNote = null;
      _actual = widget.meal.estimatedPriceMinor;
      _saveKey = _newKey();
    });
    _saveDraft();
  }

  Future<void> _save() async {
    final notifier = context.read<PurchasesNotifier>();
    final messenger = ScaffoldMessenger.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final planned = widget.meal.estimatedPriceMinor;
    final saved = _actual;
    final ok = await notifier.add(PurchaseLog(
        mealId: widget.meal.id!,
        purchasedAt: ymd(DateTime.now()),
        actualPriceMinor: saved,
        saveKey: _saveKey));
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
        content: Text(ok ? 'Purchase saved' : 'Could not save. Please try again.')));
    if (ok) {
      await _clearDraft();
      setState(() {
        _started = false;
        _savedNote =
            'Saved ${formatMinor(saved)}: ${differenceWords(planned, saved)}';
      });
      _reveal.duration =
          reduceMotion ? Duration.zero : const Duration(milliseconds: 500);
      _reveal.forward(from: 0);
      await _loadHistory();
    }
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset this plan?'),
        content: const Text('Your saved purchases are not deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _clearDraft();
      setState(() {
        _started = false;
        _actual = widget.meal.estimatedPriceMinor;
        _saveKey = _newKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final saving = context.watch<PurchasesNotifier>().saving;
    final lens = estimateNextCost(_history);
    final maxMinor = (meal.estimatedPriceMinor * 2).clamp(2000, 20000).toInt();

    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('${meal.cuisine}  |  ${meal.venueNote}'),
        const SizedBox(height: 8),
        Card(
          color: Colors.amber.shade50,
          child: ListTile(
            title: const Text('Lunch Lens (rule-based estimate)'),
            subtitle: Text(lens.hasEstimate
                ? 'Next-cost estimate ${formatMinor(lens.estimateMinor!)}\n'
                    '${lens.explanation}\n'
                    'Your planned price stays ${formatMinor(meal.estimatedPriceMinor)}.'
                : 'Not enough history'),
          ),
        ),
        ReceiptCard(
            plannedMinor: meal.estimatedPriceMinor, actualMinor: _actual),
        if (_savedNote != null)
          FadeTransition(
            opacity: _reveal,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.3), end: Offset.zero)
                  .animate(_reveal),
              child: Card(
                  color: Colors.green.shade50,
                  child: ListTile(title: Text(_savedNote!))),
            ),
          ),
        Text('Actual price: ${formatMinor(_actual)}'),
        Slider(
          value: _actual.clamp(0, maxMinor).toDouble(),
          min: 0,
          max: maxMinor.toDouble(),
          divisions: maxMinor ~/ 25,
          label: formatMinor(_actual),
          onChanged:
              _started ? (v) => setState(() => _actual = v.round()) : null,
          onChangeEnd: _started ? (_) => _saveDraft() : null,
        ),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: _started ? null : _start,
                  child: const Text('Start'))),
          const SizedBox(width: 8),
          Expanded(
              child: FilledButton(
                  onPressed: (_started && !saving) ? _save : null,
                  child: Text(saving ? 'Saving...' : 'Save purchase'))),
          const SizedBox(width: 8),
          Expanded(
              child: OutlinedButton(
                  onPressed: _started ? _reset : null,
                  child: const Text('Reset'))),
        ]),
        const SizedBox(height: 16),
        Text('Recent purchases', style: Theme.of(context).textTheme.titleMedium),
        if (_history.isEmpty) const Text('No purchases yet'),
        for (final p in _history.take(5))
          ListTile(
              dense: true,
              title: Text(formatMinor(p.actualPriceMinor)),
              subtitle: Text(p.purchasedAt)),
      ]),
    );
  }
}