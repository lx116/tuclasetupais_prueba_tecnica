/// Up to two uppercase initials of [name], or `?` when it has no letters.
String initialsOf(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2);
  if (words.isEmpty) return '?';
  return words
      .map((word) => String.fromCharCode(word.runes.first).toUpperCase())
      .join();
}
