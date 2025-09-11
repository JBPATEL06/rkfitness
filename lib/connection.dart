import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://kduqtcxujuqgsufudjfe.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkdXF0Y3h1anVxZ3N1ZnVkamZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxMzM2OTksImV4cCI6MjA3MjcwOTY5OX0.qTUG2uO7BRThGmDrLC1ZTqA3brF3VWriTGqabGX7m9E';

// This will hold the Supabase client after initialization
late final SupabaseClient supabase;

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  supabase = Supabase.instance.client;
}
