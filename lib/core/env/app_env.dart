abstract final class AppEnv {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Phase 2 — Node.js API
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const apiSecret = String.fromEnvironment('API_SECRET');
}
