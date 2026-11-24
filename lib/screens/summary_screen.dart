import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/food_entry.dart';
import '../widgets/meal_helpers.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.entries, required this.date});

  final List<FoodEntry> entries;
  final DateTime date;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'สรุปบันทึกอาหาร',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(prettyDate(date), style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.white, size: 34),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'มื้ออาหารที่บันทึก',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${entries.length} รายการ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      ...FoodEntry.meals.map((meal) {
        final count = entries.where((entry) => entry.meal == meal).length;
        return Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.cream,
              child: Icon(mealIcon(meal), color: AppColors.red),
            ),
            title: Text(meal),
            trailing: Text(
              '$count รายการ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      }),
    ],
  );
}
