import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Food Tracker opens on the food list', (tester) async {
    await tester.pumpWidget(const FoodTrackerApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Food Tracker'), findsOneWidget);
    expect(find.text('ข้าวผัดกุ้ง'), findsNothing);
    expect(find.text('สลัดอกไก่'), findsNothing);
    expect(find.text('ข้าวต้มหมู'), findsNothing);
    expect(find.text('ยังไม่มีรายการอาหาร'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('ค้นหาเมนูอาหาร'), findsOneWidget);
    expect(find.text('บันทึกอาหาร'), findsOneWidget);
  });

  testWidgets('new food is saved and remains after reopening the app', (
    tester,
  ) async {
    await tester.pumpWidget(const FoodTrackerApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Food Tracker (เพิ่ม)'), findsOneWidget);
    expect(find.text('กินอะไร'), findsOneWidget);
    expect(find.text('กินมื้อไหน'), findsOneWidget);
    expect(find.text('กินไปเท่าไหร่'), findsOneWidget);
    expect(find.text('กินกันกี่คน'), findsOneWidget);
    expect(find.text('กินไปวันไหน'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'ข้าวหน้าไก่');
    await tester.drag(find.byType(ListView).last, const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();
    expect(find.text('ข้าวหน้าไก่'), findsOneWidget);
    await tester.tap(find.text('ข้าวหน้าไก่'));
    await tester.pumpAndSettle();
    expect(find.text('Food Tracker (แก้ไข/ลบ)'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('บันทึกแก้ไข'), findsOneWidget);
    expect(find.text('ลบข้อมูล'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const FoodTrackerApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('ข้าวหน้าไก่'), findsOneWidget);
  });
}
