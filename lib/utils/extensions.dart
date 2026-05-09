import 'dart:math';

// Utility extensions and helper methods

extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Check if string is empty or whitespace
  bool get isEmptyOrWhitespace => trim().isEmpty;
}

extension ListExtensions<T> on List<T> {
  /// Get random element from list
  T getRandomElement() {
    if (isEmpty) throw Exception('Cannot get random element from empty list');
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }

  /// Shuffle list and return new list
  List<T> shuffled() {
    final list = [...this];
    list.shuffle();
    return list;
  }
}

extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get days difference
  int daysSince() {
    return DateTime.now().difference(this).inDays;
  }
}

extension DoubleExtensions on double {
  /// Round to nearest decimal places
  double roundToDecimal(int decimals) {
    final factor = pow(10, decimals);
    return (this * factor).round() / factor;
  }
}