import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/draft_service.dart';

/// Global loading message provider for Smart Inbox analysis.
/// A non-null value triggers a loading overlay in the UI.
final smartInboxLoadingProvider = StateProvider<String?>((ref) => null);

/// State notifier to manage drafts reactively across files.
class SmartInboxDraftsNotifier extends StateNotifier<List<DraftTransaction>> {
  SmartInboxDraftsNotifier() : super([]) {
    loadDrafts();
  }

  Future<void> loadDrafts() async {
    final list = await DraftService.getDrafts();
    state = list;
  }

  Future<void> addDraft(DraftTransaction draft) async {
    await DraftService.addDraft(draft);
    await loadDrafts();
  }

  Future<void> deleteDraft(String id) async {
    await DraftService.deleteDraft(id);
    await loadDrafts();
  }

  Future<void> clearAllDrafts() async {
    await DraftService.saveDrafts([]);
    state = [];
  }
}

final smartInboxDraftsProvider = StateNotifierProvider<SmartInboxDraftsNotifier, List<DraftTransaction>>((ref) {
  return SmartInboxDraftsNotifier();
});
