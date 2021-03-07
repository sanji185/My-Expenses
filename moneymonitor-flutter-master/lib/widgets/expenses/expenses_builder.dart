import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:money_monitor/models/expense.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/scoped_models/main.dart';
import 'package:money_monitor/widgets/expenses/expense_list.dart';
import 'package:money_monitor/models/category.dart';

class ExpensesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        if (model.syncStatus) {
          return ExpenseList();
        }
        return FutureBuilder(
          future: FirebaseDatabase.instance
              .reference()
              .child('users/${model.authenticatedUser.uid}')
              .once(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return new CircularProgressIndicator();
            }
            List<Expense> expenses = [];
            List<Category> categories = [];
            String theme;
            String currency;

            Map<dynamic, dynamic> categoryMap;
            Map<dynamic, dynamic> expenseMap = snapshot.data.value;
            if (expenseMap != null) {
              expenseMap.forEach((key, value) {
                if (key == "expenses") {
                  Map<dynamic, dynamic> expenseT = value;
                  expenseT.forEach((key, value) {
                    expenses.add(Expense.fromJson(key, value));
                  });
                }
                if (key == "preferences") {
                  Map<dynamic, dynamic> pref = value;
                  pref.forEach((key, value) {
                    if (key == "theme") {
                      theme = value;
                    }

                    if (key == "currency") {
                      currency = value;
                    }

                    if (key == "userCategories") {
                      categoryMap = value;
                    }
                  });
                }
              });

              if (categoryMap != null) {
                categoryMap.forEach((key, value) {
                  categories.add(Category.fromJson(key, value));
                });
              }

              model.setPreferences(theme, currency, categories);
              if (expenses.length > 0) {
                model.setExpenses(expenses);
              }
              model.toggleSynced();
            } else {
              model.gotNoData();
            }
            return ExpenseList();
          },
        );
      },
    );
  }
}
