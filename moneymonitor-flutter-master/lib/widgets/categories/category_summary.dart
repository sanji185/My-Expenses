import 'package:flutter/material.dart';

class CategorySummary extends StatelessWidget {
  final String categoryName;
  final String currency;
  final int total;

  CategorySummary(this.categoryName, this.total, this.currency);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        elevation: 1,
        child: ListTile(
          title: Text(
            categoryName,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            "$currency${total.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.start,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 50),
        ),
      ),
    );
  }
}
