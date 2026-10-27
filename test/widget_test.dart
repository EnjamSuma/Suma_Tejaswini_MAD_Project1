import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/ui/widgets.dart';

void main() {
  testWidgets('ReceiptCard says under plan in words', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ReceiptCard(plannedMinor: 750, actualMinor: 650))));
    expect(find.text('Difference: Under plan by \$1.00'), findsOneWidget);
  });

  testWidgets('SummaryCard shows percent of budget used', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SummaryCard(spentMinor: 3750, budgetMinor: 7500))));
    expect(find.text('50% of budget used'), findsOneWidget);
  });

  testWidgets('EmptyState shows its message', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EmptyState('No purchases yet'))));
    expect(find.text('No purchases yet'), findsOneWidget);
  });
}