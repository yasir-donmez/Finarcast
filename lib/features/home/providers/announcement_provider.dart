import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';

/// FutureProvider that fetches active announcements from Supabase.
/// Returns an empty list on failure or if offline.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  try {
    final response = await Supabase.instance.client
        .from('announcements')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final list = response as List;
    return list.map((json) => Announcement.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    // Return empty list on any error (table not created, offline, etc.) to prevent app crashes
    return [];
  }
});
