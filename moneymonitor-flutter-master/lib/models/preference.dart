import 'package:money_monitor/models/category.dart';

class Preferences {
  String theme;
  String currency;
  List<Category> categories;

  Preferences(this.theme, this.currency, this.categories);

  set updateCategories(List<Category> newCategories) {
    categories = newCategories;
  }

  set updateTheme(String newTheme) {
    theme = newTheme;
  }

  set updateCurrency(String newCurrency) {
    currency = newCurrency;
  }
}
