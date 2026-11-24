import 'package:flutter/material.dart';

IconData mealIcon(String meal) => switch (meal) {
  'เช้า' => Icons.wb_sunny_outlined,
  'กลางวัน' => Icons.light_mode_outlined,
  'เย็น' => Icons.nights_stay_outlined,
  _ => Icons.cookie_outlined,
};
