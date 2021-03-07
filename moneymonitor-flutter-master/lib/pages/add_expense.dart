import 'package:flutter/material.dart';
import 'package:money_monitor/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/scoped_models/main.dart';
import 'package:money_monitor/models/category.dart';

class AddExpense extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddExpenseState();
  }
}

class _AddExpenseState extends State<AddExpense> {
  String _categoryVal = '0';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "title": null,
    "amount": null,
    "createdAt": DateTime.now().millisecondsSinceEpoch,
    "note": "",
  };

  _buildTitleField() {
    return Card(
      clipBehavior: Clip.none,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextFormField(
        validator: (String value) {
          if (value.length <= 0) {
            return "Please enter a title for your expense";
          }
        },
        onSaved: (String value) => _formData["title"] = value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30.0),
          ),
          hintText: "Title",
          hintStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          hasFloatingPlaceholder: true,
          prefix: Text("  "),
          filled: true,
          fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  _buildAmountField(String currency) {
    return Card(
      clipBehavior: Clip.none,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30.0),
          ),
          hintText: "Amount",
          hintStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          prefix: Text("$currency "),
          hasFloatingPlaceholder: true,
          filled: true,
          fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onSaved: (String value) => _formData["amount"] = value,
        validator: (String value) {
          if (!RegExp(
                  r"^\-?\(?\$?\s*\-?\s*\(?(((\d{1,3}((\,\d{3})*|\d*))?(\.\d{1,4})?)|((\d{1,3}((\,\d{3})*|\d*))(\.\d{0,4})?))\)?$")
              .hasMatch(value)) {
            return "Please enter a valid amount\n";
          }

          if (value.length == 0) {
            return "An amount is required.";
          }
        },
      ),
    );
  }

  String findCategoryName(String id, List<Category> categories) {
    Category cat = categories.firstWhere((category) => category.id == id);
    return cat.name;
  }

  _buildCategorySelector(List<Category> categories) {
    List<Category> output = [Category("0", "None")];
    output.addAll(categories);

    return Card(
      clipBehavior: Clip.none,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: MaterialButton(
        minWidth: 200,
        child: Text(
          _categoryVal == null || _categoryVal == "0"
              ? "Select Category (optional)"
              : findCategoryName(_categoryVal, categories),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 300,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: output.length,
                        itemBuilder: (BuildContext context, int index) {
                          return RadioListTile(
                            activeColor: Theme.of(context).accentColor,
                            groupValue: _categoryVal,
                            value: output[index].id,
                            title: Text(output[index].name),
                            onChanged: (String value) {
                              Navigator.pop(context);
                              _categoryVal = value;
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  _showDateOption() {
    return Card(
      clipBehavior: Clip.none,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: MaterialButton(
        minWidth: 100,
        child: Text("Date"),
        onPressed: () async {
          DateTime date = await showDatePicker(
            context: context,
            initialDate:
                DateTime.fromMillisecondsSinceEpoch(_formData["createdAt"]),
            firstDate: DateTime(2000),
            lastDate: DateTime(3000),
          );
          if (date != null) {
            _formData["createdAt"] = date.millisecondsSinceEpoch;
          }
        },
      ),
    );
  }

  _buildNoteField() {
    return Card(
      clipBehavior: Clip.none,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextFormField(
        onSaved: (String value) => _formData["note"] = value,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30.0),
          ),
          hintText: "Note",
          hintStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          hasFloatingPlaceholder: true,
          prefix: Text("  "),
          filled: true,
          fillColor: deviceTheme == "light" ? Colors.white : Colors.grey[600],
        ),
        maxLines: 5,
      ),
    );
  }

  _buildSaveButton(Function addExpense) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: deviceTheme == "light"
            ? Theme.of(context).accentColor
            : Colors.grey[800],
      ),
      child: MaterialButton(
        onPressed: () {
          if (!_formKey.currentState.validate()) {
            return "";
          }

          _formKey.currentState.save();

          String category = _categoryVal == "0" ? "6" : _categoryVal;
          addExpense(
            title: _formData["title"],
            amount: _formData['amount'],
            createdAt: _formData['createdAt'],
            note: _formData['note'],
            category: category,
            context: context,
          );
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Save Expense",
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildCancelButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: deviceTheme == "light"
            ? Theme.of(context).accentColor
            : Colors.grey[800],
      ),
      child: MaterialButton(
        minWidth: 150,
        onPressed: () => Navigator.of(context).pop(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cancel,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildForm(model) {
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              _buildTitleField(),
              SizedBox(
                height: 10,
              ),
              _buildAmountField(model.userCurrency),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildCategorySelector(model.allCategories),
                  SizedBox(
                    width: 15.0,
                  ),
                  _showDateOption(),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              _buildNoteField(),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildSaveButton(model.addExpense),
                  SizedBox(
                    width: 10,
                  ),
                  _buildCancelButton(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, _, MainModel model) {
        return Scaffold(
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: deviceTheme == "light"
                      ? Theme.of(context).accentColor
                      : Colors.grey[900],
                  expandedHeight: 80,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                      child: SafeArea(
                        bottom: false,
                        top: true,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Add",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  "expense",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      _buildForm(model),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
