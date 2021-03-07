import 'package:flutter/material.dart';
import 'package:money_monitor/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/models/category.dart';
import 'package:money_monitor/main.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class SideDrawer extends StatefulWidget {
  final Function updateCategoryFilter;
  final Function updateSort;
  final String sortByVal;
  final DateTime startDate;
  final DateTime endDate;
  final List<Category> allCategories;
  SideDrawer(this.updateCategoryFilter, this.updateSort, this.sortByVal,
      this.allCategories, this.startDate, this.endDate);

  @override
  State<StatefulWidget> createState() {
    return _SideDrawerState();
  }
}

class _SideDrawerState extends State<SideDrawer> {
  String _sortByValue;
  List<Category> categories;
  DateTime _startDate;
  DateTime _endDate;
  bool clearAllButton = true;

  @override
  void initState() {
    _sortByValue = widget.sortByVal;
    categories = widget.allCategories;
    _startDate = widget.startDate == null ? DateTime.now() : widget.startDate;
    _endDate = widget.endDate == null
        ? DateTime.now().add(new Duration(days: 7))
        : widget.endDate;
    super.initState();
  }

  void _changeSortValue(String value) {
    setState(() {
      _sortByValue = value;
    });
  }

  final GlobalKey key = GlobalKey();

  @override
  void dispose() {
    widget.updateCategoryFilter(categories);
    widget.updateSort(_sortByValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        return SizedBox(
          width: 315,
          child: Drawer(
            key: key,
            child: Column(
              children: <Widget>[
                Container(
                  height: 120.0,
                  child: DrawerHeader(
                    child: Row(
                      children: <Widget>[
                        // TODO Add Logo
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Money Monitor",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: deviceTheme == "light"
                          ? Theme.of(context).primaryColorLight
                          : Colors.grey[900],
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Row(
                    children: <Widget>[
                      Text("Date Range"),
                      SizedBox(
                        width: 55,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20.0,
                        ),
                        onPressed: () async {
                          final List<DateTime> range =
                              await DateRangePicker.showDatePicker(
                            context: context,
                            initialFirstDate: _startDate,
                            initialLastDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000),
                          );

                          if (range != null && range.length == 2) {
                            model.updateDateRange(range[0], range[1]);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20.0,
                        ),
                        onPressed: () {
                          model.updateDateRange(null, null);
                        },
                      ),
                    ],
                  ),
                ),
                ExpansionTile(
                  initiallyExpanded: false,
                  title: Text("Sort By"),
                  leading: Icon(
                    (Icons.sort),
                  ),
                  children: <Widget>[
                    RadioListTile(
                      activeColor: Theme.of(context).accentColor,
                      onChanged: _changeSortValue,
                      groupValue: _sortByValue,
                      value: "date",
                      title: Text("Date"),
                    ),
                    RadioListTile(
                      activeColor: Theme.of(context).accentColor,
                      onChanged: _changeSortValue,
                      groupValue: _sortByValue,
                      value: "amount",
                      title: Text("Amount"),
                    ),
                    RadioListTile(
                      activeColor: Theme.of(context).accentColor,
                      onChanged: _changeSortValue,
                      groupValue: _sortByValue,
                      value: "category",
                      title: Text("Category"),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15.0,
                    ),
                    Icon(Icons.filter_list),
                    SizedBox(
                      width: 33.0,
                    ),
                    Text("Filter Categories"),
                    SizedBox(
                      width: 39.0,
                    ),
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          categories.forEach((category) {
                            category.updateVisibility(true);
                          });
                        });
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          categories.forEach((category) {
                            category.updateVisibility(false);
                          });
                        });
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ],
                ),
                Container(
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          activeColor: Theme.of(context).accentColor,
                          onChanged: (value) {
                            setState(
                              () {
                                categories[index].updateVisibility(value);
                              },
                            );
                          },
                          value: categories[index].show,
                          title: Text(categories[index].name),
                        );
                      },
                    ),
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
