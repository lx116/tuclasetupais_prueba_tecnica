final RegExp _accented = RegExp(r'[áàäâãéèëêíìïîóòöôõúùüûñç]');

const Map<String, String> _plain = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', //
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', //
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', //
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o', //
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', //
  'ñ': 'n', 'ç': 'c',
};

/// Lowercases [value] and removes Spanish accents, to compare text without
/// caring about case or accents ("Ingeniería" -> "ingenieria").
String foldText(String value) => value.toLowerCase().replaceAllMapped(
  _accented,
  (match) => _plain[match.group(0)]!,
);
