import 'package:multi_select_flutter/multi_select_flutter.dart';

class AppTags {
  static List<String> get tags => [
        "Boteco",
        "Balada",
        "Ar Livre",
        "Bar",
        "Religioso",
        "Executivo",
        "Acadêmico",
        "Arte",
        "Funk",
        "Pop",
        "Rock",
        "Pagode",
        "Gospel",
        "Rap",
        "Sem Álcool",
        "Crianças"
      ];

  static List<MultiSelectItem<String>> get items =>
      AppTags.tags.map((t) => MultiSelectItem(t, t)).toList();
}
