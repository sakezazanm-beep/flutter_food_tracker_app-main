import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const storageBucket = String.fromEnvironment(
    'SUPABASE_STORAGE_BUCKET',
    defaultValue: 'food_tracker_bk',
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}

SupabaseClient? get supabaseClient =>
    AppConfig.hasSupabase ? Supabase.instance.client : null;
