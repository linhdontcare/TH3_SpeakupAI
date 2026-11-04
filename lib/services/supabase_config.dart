class SupabaseConfig {
  // =========================================================================
  // THÔNG TIN KẾT NỐI SUPABASE CHÍNH THỨC CỦA BẠN (speakupai):
  // =========================================================================
  static const String supabaseUrl = 'https://cdrtpbjerdcihjnzwykm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkcnRwYmplcmRjaWhqbnp3eWttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM1MzUwMTEsImV4cCI6MjEwOTExMTAxMX0.tohnePY_jncoEJfSTh4wRNi-iLHh9t1BlNrQib06N0M';

  // Kiểm tra xem đã cấu hình hợp lệ chưa
  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      supabaseUrl.trim().isNotEmpty &&
      supabaseAnonKey.trim().isNotEmpty;
}
