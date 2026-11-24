import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';
import '../models/food_entry.dart';

/// Keeps database and Storage access out of the UI screens.
class FoodRepository {
  static const _localEntriesKey = 'food_tracker_local_entries_v1';
  static const _localSeededKey = 'food_tracker_local_seeded_v1';

  SupabaseClient? get _client => supabaseClient;

  Future<List<FoodEntry>> fetchEntries() async {
    final client = _client;
    if (client == null) return _readLocalEntries();
    final rows = await client
        .from('food_tracker_tb')
        .select()
        .order('foodDate', ascending: false);
    return (rows as List).map((row) => FoodEntry.fromMap(row)).toList();
  }

  /// Removes the old built-in sample foods while keeping user-created entries.
  Future<List<FoodEntry>> initializeLocalEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await _readLocalEntries();
    const sampleIds = {'demo-1', 'demo-2', 'demo-3'};
    final cleaned = entries
        .where((entry) => !sampleIds.contains(entry.id))
        .toList();
    if (cleaned.length != entries.length ||
        !(preferences.getBool(_localSeededKey) ?? false)) {
      await _writeLocalEntries(cleaned);
      await preferences.setBool(_localSeededKey, true);
    }
    return cleaned;
  }

  Future<FoodEntry> save(
    FoodEntry entry, {
    required bool isNew,
    String? previousImageUrl,
    Uint8List? newImageBytes,
    String? imageName,
  }) async {
    final client = _client;
    if (client == null) {
      final entries = await _readLocalEntries();
      entries.removeWhere((item) => item.id == entry.id);
      entries.insert(0, entry);
      await _writeLocalEntries(entries);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_localSeededKey, true);
      return entry;
    }

    final userId = client.auth.currentUser!.id;
    var imageUrl = entry.imageUrl;
    final oldImagePath = _storagePath(previousImageUrl ?? entry.imageUrl);
    String? newImagePath;

    if (newImageBytes != null) {
      final extension = _extension(imageName);
      newImagePath = '$userId/${entry.id}.$extension';
      await client.storage
          .from(AppConfig.storageBucket)
          .uploadBinary(
            newImagePath,
            newImageBytes,
            fileOptions: FileOptions(
              contentType: _mimeType(extension),
              upsert: true,
            ),
          );
      imageUrl = client.storage
          .from(AppConfig.storageBucket)
          .getPublicUrl(newImagePath);
    }

    final saved = FoodEntry(
      id: entry.id,
      name: entry.name,
      meal: entry.meal,
      date: entry.date,
      amount: entry.amount,
      people: entry.people,
      imageUrl: imageUrl,
      imageBytes: entry.imageBytes,
    );
    final data = saved.toMap(userId: userId);
    if (isNew) {
      await client.from('food_tracker_tb').insert(data);
    } else {
      await client.from('food_tracker_tb').update(data).eq('id', entry.id);
    }

    if (oldImagePath != null &&
        (newImagePath != null || imageUrl == null) &&
        oldImagePath != newImagePath) {
      try {
        await client.storage.from(AppConfig.storageBucket).remove([
          oldImagePath,
        ]);
      } catch (_) {
        // Keep the saved database row; the old image can be cleaned up later.
      }
    }
    return saved;
  }

  Future<void> delete(FoodEntry entry) async {
    final client = _client;
    if (client == null) {
      final entries = await _readLocalEntries();
      entries.removeWhere((item) => item.id == entry.id);
      await _writeLocalEntries(entries);
      return;
    }
    await client.from('food_tracker_tb').delete().eq('id', entry.id);
    final imagePath = _storagePath(entry.imageUrl);
    if (imagePath != null) {
      try {
        await client.storage.from(AppConfig.storageBucket).remove([imagePath]);
      } catch (_) {
        // A failed image cleanup should not make a deleted food entry look saved.
      }
    }
  }

  Future<List<FoodEntry>> _readLocalEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final rows = preferences.getStringList(_localEntriesKey) ?? const [];
    return rows
        .map(
          (row) => FoodEntry.fromMap(jsonDecode(row) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> _writeLocalEntries(List<FoodEntry> entries) async {
    final preferences = await SharedPreferences.getInstance();
    final rows = entries.map((entry) {
      final map = <String, dynamic>{
        'id': entry.id,
        'foodName': entry.name,
        'foodMeal': entry.meal,
        'foodDate': dateKey(entry.date),
        'foodAmount': entry.amount,
        'foodPeople': entry.people,
        'foodImage': entry.imageUrl,
      };
      if (entry.imageBytes != null) {
        map['imageBytes'] = base64Encode(entry.imageBytes!);
      }
      return jsonEncode(map);
    }).toList();
    await preferences.setStringList(_localEntriesKey, rows);
  }

  String? _storagePath(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    final marker = '/object/public/${AppConfig.storageBucket}/';
    if (uri?.path.contains(marker) != true) return null;
    return Uri.decodeComponent(uri!.path.split(marker).last);
  }

  String _extension(String? name) {
    final raw = name?.split('.').last.toLowerCase();
    return switch (raw) {
      'png' || 'webp' || 'heic' => raw!,
      _ => 'jpg',
    };
  }

  String _mimeType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    _ => 'image/jpeg',
  };
}
