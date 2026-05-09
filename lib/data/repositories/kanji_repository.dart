import 'package:jap_n5_learn/models/kanji_model.dart';
import 'package:jap_n5_learn/data/datasources/kanji_data.dart';

/// Repository for accessing Kanji data
class KanjiRepository {
  /// Get all kanji for a specific week and day
  List<KanjiModel> getKanjiByWeekDay(int week, int day) {
    return KanjiDataSource.getKanjiByWeekDay(week, day);
  }

  /// Get all kanji for a week
  List<KanjiModel> getKanjiByWeek(int week) {
    return KanjiDataSource.getKanjiByWeek(week);
  }

  /// Get kanji by ID
  KanjiModel? getKanjiById(String id) {
    return KanjiDataSource.getKanjiById(id);
  }

  /// Get all kanji
  List<KanjiModel> getAllKanji() {
    return KanjiDataSource.getAllKanji();
  }

  /// Get kanji by list of IDs
  List<KanjiModel> getKanjiByIds(List<String> ids) {
    return KanjiDataSource.getAllKanji()
        .where((k) => ids.contains(k.id))
        .toList();
  }

  /// Search kanji
  List<KanjiModel> searchKanji(String query) {
    return KanjiDataSource.searchKanji(query);
  }

  /// Get unlearned kanji for a week/day (excluding learned ones)
  List<KanjiModel> getUnlearnedKanjiByWeekDay(
    int week,
    int day,
    Set<String> learnedKanjiIds,
  ) {
    final kanji = getKanjiByWeekDay(week, day);
    return kanji.where((k) => !learnedKanjiIds.contains(k.id)).toList();
  }

  /// Get weak kanji (ones with incorrect answers)
  List<KanjiModel> getWeakKanji(Set<String> weakKanjiIds) {
    return getKanjiByIds(weakKanjiIds.toList());
  }

  /// Get total kanji count
  int getTotalKanjiCount() {
    return getAllKanji().length;
  }

  /// Get kanji count for a week
  int getKanjiCountByWeek(int week) {
    return getKanjiByWeek(week).length;
  }
}
