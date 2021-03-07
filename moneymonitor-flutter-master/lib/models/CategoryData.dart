import 'package:charts_flutter/flutter.dart' as charts;
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';


class CategoryData {
  final int id;
  final int count;
  charts.Color color;
  final String name;
  final int total;

  CategoryData(this.id, this.count, this.name, this.total) {
    this.color = _getRandomColor();
  }

    charts.Color _getRandomColor() {
    RandomColor _randomColor = RandomColor();
    Color _color = _randomColor.randomColor(colorHue: ColorHue.blue);
    String c = _color
        .toString()
        .replaceFirst("Color", "")
        .replaceFirst("(", "")
        .replaceFirst(")", "")
        .replaceFirst("0xff", "");
    return charts.Color.fromHex(code: "#$c");
  }
}