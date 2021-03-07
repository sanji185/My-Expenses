import 'package:flutter/material.dart';
import 'package:money_monitor/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/scoped_models/main.dart';
import 'package:money_monitor/widgets/categories/category_summary.dart';
import 'package:money_monitor/utils/data_cruncher.dart';

class ExpenseOverview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpenseOverviewState();
  }
}

class _ExpenseOverviewState extends State<ExpenseOverview> {
  final dataCruncher = DataCruncher();
  String timeSummary = "week";

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        List topCategories = dataCruncher.getTopCategories(
            model.allCategories, model.allExpenses, model.userCurrency);

        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(
                  FocusNode(),
                ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: deviceTheme == "light"
                        ? Theme.of(context).accentColor
                        : Colors.grey[900],
                    expandedHeight: 240,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        child: SafeArea(
                          bottom: false,
                          top: true,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 30),
                                child: Text(
                                  "Expense Overview",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    "Total Expenses:",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "${model.userCurrency}${dataCruncher.getTotal(model.allExpenses).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (timeSummary == "month") {
                                    setState(() {
                                      timeSummary = "week";
                                    });
                                  } else if (timeSummary == "week") {
                                    setState(() {
                                      timeSummary = "month";
                                    });
                                  }
                                },
                                child: Column(
                                  children: <Widget>[
                                    // Toggle month//week/year
                                    Text(
                                      "Total This ${timeSummary == "month" ? "Month" : "Week"}:",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      timeSummary == "month"
                                          ? "${model.userCurrency}${dataCruncher.getMonthTotal(model.allExpenses).toStringAsFixed(2)}"
                                          : "${model.userCurrency}${dataCruncher.getWeekTotal(model.allExpenses).toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                        child: PreferredSize(
                      preferredSize: Size.fromHeight(50.0),
                      child: Container(
                        color: deviceTheme == "light"
                            ? Theme.of(context).accentColor
                            : Colors.grey[900],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Breakdown by Category',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25.0),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    )),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return CategorySummary(topCategories[index].name,
                            topCategories[index].total, model.userCurrency);
                      },
                      childCount: topCategories.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  _SliverAppBarDelegate({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return child;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => child.preferredSize.height;

  @override
  // TODO: implement minExtent
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }
}
/*

Container(
                              height: 200,
                              child: charts.PieChart(
                                seriesData,
                                animate: true,
                                defaultRenderer: new charts.ArcRendererConfig(
                                  layoutPaintOrder: 1,
                                  arcRendererDecorators: [
                                    charts.ArcLabelDecorator(
                                      labelPosition:
                                          charts.ArcLabelPosition.auto,
                                      leaderLineStyleSpec:
                                          charts.ArcLabelLeaderLineStyleSpec(
                                              color: charts.Color.white,
                                              length: 15,
                                              thickness: 1),
                                      insideLabelStyleSpec:
                                          charts.TextStyleSpec(
                                        color: charts.Color.white,
                                        fontSize: 8,
                                      ),
                                      outsideLabelStyleSpec:
                                          charts.TextStyleSpec(
                                        color: charts.Color.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )

*/
