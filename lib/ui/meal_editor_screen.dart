import 'package:flutter/material.dart';
import '../core/money.dart';
import '../data/models.dart';

class MealEditorScreen extends StatefulWidget {
  final Meal? meal; // null means create
  const MealEditorScreen({super.key, this.meal});
  @override
  State<MealEditorScreen> createState() => _MealEditorScreenState();
}

class _MealEditorScreenState extends State<MealEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _venue;
  late final TextEditingController _price;
  late String _cuisine;

  @override
  void initState() {
    super.initState();
    final m = widget.meal;
    _name = TextEditingController(text: m?.name ?? '');
    _venue = TextEditingController(text: m?.venueNote ?? '');
    _price = TextEditingController(
        text: m == null ? '' : formatMinor(m.estimatedPriceMinor).substring(1));
    _cuisine = m?.cuisine ?? cuisines.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _venue.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
        context,
        Meal(
          id: widget.meal?.id,
          name: _name.text.trim(),
          venueNote: _venue.text.trim(),
          cuisine: _cuisine,
          estimatedPriceMinor: parseToMinor(_price.text)!,
        ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(widget.meal == null ? 'Add Meal' : 'Edit Meal')),
        body: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name *'),
              maxLength: 40,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            TextFormField(
              controller: _venue,
              decoration: const InputDecoration(
                  labelText: 'Venue note (your own note)'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _cuisine,
              decoration: const InputDecoration(labelText: 'Cuisine'),
              items: [for (final c in cuisines)
                DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => _cuisine = v!),
            ),
            TextFormField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Estimated price (\$) *',
                  helperText: 'Your own estimate, not a live listing'),
              validator: (v) => parseToMinor(v ?? '') == null
                  ? 'Enter a price of 0 or more, like 7.50'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(
                  child: FilledButton(
                      onPressed: _save, child: const Text('Save'))),
            ]),
          ]),
        ),
      );
}