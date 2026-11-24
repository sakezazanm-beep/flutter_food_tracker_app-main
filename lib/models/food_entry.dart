import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    required this.meal,
    required this.date,
    this.amount = 0,
    this.people = 1,
    this.imageUrl,
    this.imageBytes,
  });

  static const meals = ['เช้า', 'กลางวัน', 'เย็น', 'ว่าง'];

  final String id;
  final String name;
  final String meal;
  final DateTime date;
  final double amount;
  final int people;
  final String? imageUrl;
  final Uint8List? imageBytes;

  factory FoodEntry.fromMap(Map<String, dynamic> map) => FoodEntry(
    id: map['id'].toString(),
    name: map['foodName'] as String? ?? '',
    meal: map['foodMeal'] as String? ?? 'ว่าง',
    amount: (map['foodAmount'] as num?)?.toDouble() ?? 0,
    people: (map['foodPeople'] as num?)?.toInt() ?? 1,
    date:
        DateTime.tryParse(map['foodDate']?.toString() ?? '') ?? DateTime.now(),
    imageUrl: map['foodImage'] as String?,
    imageBytes: map['imageBytes'] is String
        ? base64Decode(map['imageBytes'] as String)
        : null,
  );

  Map<String, dynamic> toMap({String? userId}) => {
    'foodName': name,
    'foodMeal': meal,
    'foodAmount': amount,
    'foodPeople': people,
    'foodDate': dateKey(date),
    'foodImage': imageUrl,
    'user_id': ?userId,
  };
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String prettyDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String newUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
