import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration options for the application.
/// 
/// Usage:
/// ```dart
/// import 'package:threadly/supabase_options.dart';
/// 
/// await Supabase.initialize(
///   url: SupabaseConfig.supabaseUrl,
///   anonKey: SupabaseConfig.supabaseAnonKey,
/// );
/// ```
class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
  static String? get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'];
}
