/// Model representing a single Kanji character
class KanjiModel {
  final String id;
  final String kanji;
  final String meaning;
  final String onyomi;
  final String kunyomi;
  final List<String> examples; // Example words
  final int strokeCount;
  final int week;
  final int day;

  KanjiModel({
    required this.id,
    required this.kanji,
    required this.meaning,
    required this.onyomi,
    required this.kunyomi,
    required this.examples,
    required this.strokeCount,
    required this.week,
    required this.day,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'kanji': kanji,
    'meaning': meaning,
    'onyomi': onyomi,
    'kunyomi': kunyomi,
    'examples': examples,
    'strokeCount': strokeCount,
    'week': week,
    'day': day,
  };

  // Create from JSON
  factory KanjiModel.fromJson(Map<String, dynamic> json) => KanjiModel(
    id: json['id'],
    kanji: json['kanji'],
    meaning: json['meaning'],
    onyomi: json['onyomi'],
    kunyomi: json['kunyomi'],
    examples: List<String>.from(json['examples']),
    strokeCount: json['strokeCount'],
    week: json['week'],
    day: json['day'],
  );

  @override
  String toString() => 'KanjiModel($kanji - $meaning)';
}
