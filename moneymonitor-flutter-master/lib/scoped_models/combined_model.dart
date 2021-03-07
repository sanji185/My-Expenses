import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/models/user.dart';
import 'package:money_monitor/models/expense.dart';
import 'package:money_monitor/models/preference.dart';
import 'package:money_monitor/models/category.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

final List<Category> defaultCategories = [
  Category("1", "Bills", MdiIcons.fileDocument),
  Category("2", "Rent", Icons.home),
  Category("3", "Food", MdiIcons.foodForkDrink),
  Category("4", "Leisure", MdiIcons.shopping),
  Category("5", "Debt", Icons.monetization_on),
  Category("6", "Miscellaneous", MdiIcons.cashRegister),
];

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColorLight: Colors.white,
  accentColor: Colors.blueAccent,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColorLight: Colors.grey,
);

mixin CombinedModel on Model {
  User _authUser;
  List<Expense> _expenses = [];
  bool _synced = false;
  DateTime _lastUpdated;
  String _newName;
  Preferences _userPreferences;
  String _sortBy = "date";
  String _searchQuery = "";
  DateTime startDate;
  DateTime endDate;

  bool get syncStatus {
    return _synced;
  }

  String get newName {
    return _newName;
  }

  DateTime get lastUpdate {
    return _lastUpdated;
  }

  void toggleSynced() {
    _synced = !_synced;
  }

  void gotNoData() {
    _expenses = [];
  }

  void loginUser(displayName, uid, email, photoUrl) {
    _authUser = User(
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      uid: uid,
    );
  }
}

mixin FilterModel on CombinedModel {
  Category expenseCategory(String categoryId) {
    Category cat = _userPreferences.categories.firstWhere(
        (category) => category.id == categoryId,
        orElse: () => Category("0", ""));
    return cat;
  }

  List<Category> get allCategories {
    return _userPreferences.categories;
  }

  void updateCategoryFilter(List<Category> newCategories) {
    _userPreferences.categories = newCategories;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.toLowerCase();
    notifyListeners();
  }

  void updateSort(String value) {
    _sortBy = value;
    notifyListeners();
  }

  void updateDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }

  void updateCurrency(String currency) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('users/${_authUser.uid}/preferences/currency');
    String value;
    if (currency == "£") {
      value = "en-gb";
    } else if (currency == "\$") {
      value = "en";
    } else if (currency == "€") {
      value = "fr";
    }

    await ref.set(value);

    _userPreferences.currency = currency;
    notifyListeners();
  }

  String get sortBy {
    return _sortBy;
  }

  String get userTheme {
    return _userPreferences.theme;
  }

  String get userCurrency {
    if (_userPreferences != null) {
      return _userPreferences.currency;
    } else {
      return null;
    }
  }

  String formatDate(DateTime date) {
    List<String> _date = date.toIso8601String().substring(0, 10).split("-");
    if (_userPreferences.currency == '\$') {
      return "${_date[1]}-${_date[2]}-${_date[0]}";
    } else {
      return "${_date[2]}-${_date[1]}-${_date[0]}";
    }
  }

  void updateTheme(String theme) {
    _userPreferences.theme = theme;
    notifyListeners();
  }

  void setPreferences(
      String theme, String currency, List<Category> categories) {
    String actualCurrency = "";
    if (currency == "en-gb") {
      actualCurrency = '£';
    } else if (currency == 'fr') {
      actualCurrency = '€';
    } else {
      actualCurrency = '\$';
    }

    List<Category> allCategories = List.from(defaultCategories)
      ..addAll(categories);
    _userPreferences = Preferences(theme, actualCurrency, allCategories);
  }
}

mixin ExpensesModel on CombinedModel {
  List<Expense> get allExpenses {
    return List.from(_expenses);
  }

  List<Expense> get filteredExpenses {
    List<Expense> output = [];

    _expenses.forEach(
      (expense) {
        if (expense != null) {
          Category category = _userPreferences.categories.firstWhere(
              (category) => category.id == expense.category,
              orElse: () => Category("0", "empty"));
          if (category.show || category.name == "empty") {
            output.add(expense);
          }
        }
      },
    );

    List<Expense> rangeFilter = output;

    if (startDate != null && endDate != null) {
      rangeFilter = output.where((expense) {
        int expenseDate = int.parse(expense.createdAt);
        int _startDate = startDate.millisecondsSinceEpoch;
        int _endDate = endDate.millisecondsSinceEpoch;

        return expenseDate >= _startDate && expenseDate <= _endDate;
      }).toList();
    }

    List<Expense> finalOutput = rangeFilter.where((expense) {
      return expense.title.toLowerCase().contains(_searchQuery) ||
          expense.note.toLowerCase().contains(_searchQuery);
    }).toList();

    finalOutput.sort(
      (a, b) {
        if (_sortBy == "date") {
          return b.createdAt.compareTo(a.createdAt);
        } else if (_sortBy == "amount") {
          return double.parse(a.amount) < double.parse(b.amount) ? 1 : -1;
        } else if (_sortBy == "category") {
          return a.category.compareTo(b.category);
        }
      },
    );

    return finalOutput;
  }

  void setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  void backupExpenses() async {
    // Testing Backup Feature!
    List<String> jsonList = [];
    String jv = jsonEncode(_expenses);
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    File expenseBackup = File("${directory.path}/expenseBackup.json");
    expenseBackup.writeAsString(jv).catchError((error) {
      print(error);
    });

    // List<Expense> list = [];
    // print(jv);
    // List<dynamic> a = jsonDecode(jv);
    // a.forEach((val) {
    //   Map<String, dynamic>  help = {};
    //   val.forEach((key, value) {
    //     help[key] = value;
    //   });
    //   print(help);
    //   list.add(Expense.fromJson(help["key"], help));
    // });
  }

  void restoreExpense() async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    File expenseBackup = File("${directory.path}/expenseBackup.json");
    String data = await expenseBackup.readAsString();
    List<Expense> list = [];
    print(data);
    List<dynamic> a = jsonDecode(data);
    a.forEach((val) {
      Map<String, dynamic> help = {};
      val.forEach((key, value) {
        help[key] = value;
      });
      print(help);
      list.add(Expense.fromJson(help["key"], help));
    });
    _expenses = list;
  }

  void clearExpenses() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('users/${_authUser.uid}/expenses');
    await ref.remove();

    _expenses = [];
    notifyListeners();
  }

  void addExpense({
    String title,
    String amount,
    int createdAt,
    String note,
    String category,
    BuildContext context,
  }) async {
    print("$title | $amount | $createdAt | $note | $category");

    Map<String, dynamic> newExpense = {
      "title": title,
      "amount": double.parse(amount) * 100,
      "createdAt": createdAt,
      "note": note,
      "category": category
    };

    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('users/${_authUser.uid}/expenses')
        .push();
    await ref.set(newExpense);

    _expenses.add(Expense(
        title: title,
        amount: (double.parse(amount) * 100).toString(),
        createdAt: createdAt.toString(),
        note: note,
        category: category,
        key: ref.key));

    notifyListeners();
  }

  void editExpense({
    String title,
    String amount,
    int createdAt,
    String note,
    String category,
    BuildContext context,
    String key,
  }) async {
    print(key);
    Map<String, dynamic> newExpense = {
      "title": title,
      "amount": double.parse(amount) * 100,
      "createdAt": createdAt,
      "note": note,
      "category": category
    };

    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('users/${_authUser.uid}/expenses/$key');
    await ref.set(newExpense);

    _expenses = _expenses.map((expense) {
      if (expense.key == key) {
        expense.amount = (double.parse(amount) * 100).toString();
        expense.title = title;
        expense.createdAt = createdAt.toString();
        expense.note = note;
        expense.category = category;
        return expense;
      } else {
        return expense;
      }
    }).toList();

    notifyListeners();
  }

  void deleteExpense(String key) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('users/${_authUser.uid}/expenses/$key');
    await ref.remove();

    _expenses.removeWhere((expense) => expense.key == key);

    notifyListeners();
  }
}

mixin UserModel on CombinedModel {
  User get authenticatedUser {
    return _authUser;
  }

  void changeUserName(String name) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    UserUpdateInfo updates = UserUpdateInfo();
    updates.displayName = name;
    await user.updateProfile(updates);
    updateUserName(name);
  }

  void updateUserName(String newName) {
    _authUser = User(
      displayName: newName,
      uid: _authUser.uid,
      photoUrl: _authUser.photoUrl,
      email: _authUser.email,
    );
    notifyListeners();
  }

  void logoutUser() {
    _authUser = null;
    _lastUpdated = null;
    _expenses = [];
    toggleSynced();
    notifyListeners();
  }
}
