const cuisines = ['Asian', 'Mexican', 'American', 'Other'];

class Meal {
  final int? id;
  final String name;
  final String venueNote;
  final String cuisine;
  final int estimatedPriceMinor; // cents, so $7.50 is 750

  const Meal({
    this.id,
    required this.name,
    this.venueNote = '',
    required this.cuisine,
    required this.estimatedPriceMinor,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'venue_note': venueNote,
        'cuisine': cuisine,
        'estimated_price_minor': estimatedPriceMinor,
      };

  factory Meal.fromMap(Map<String, Object?> m) => Meal(
        id: m['id'] as int?,
        name: m['name'] as String,
        venueNote: m['venue_note'] as String,
        cuisine: m['cuisine'] as String,
        estimatedPriceMinor: m['estimated_price_minor'] as int,
      );
}

class PurchaseLog {
  final int? id;
  final int mealId;
  final String purchasedAt; // 'yyyy-MM-dd'
  final int actualPriceMinor;
  final String note;
  final String status; // 'draft' or 'final'
  final String saveKey; // unique per form, stops double saves

  const PurchaseLog({
    this.id,
    required this.mealId,
    required this.purchasedAt,
    required this.actualPriceMinor,
    this.note = '',
    this.status = 'final',
    required this.saveKey,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'meal_id': mealId,
        'purchased_at': purchasedAt,
        'actual_price_minor': actualPriceMinor,
        'note': note,
        'status': status,
        'save_key': saveKey,
      };

  factory PurchaseLog.fromMap(Map<String, Object?> m) => PurchaseLog(
        id: m['id'] as int?,
        mealId: m['meal_id'] as int,
        purchasedAt: m['purchased_at'] as String,
        actualPriceMinor: m['actual_price_minor'] as int,
        note: m['note'] as String,
        status: m['status'] as String,
        saveKey: m['save_key'] as String,
      );
}