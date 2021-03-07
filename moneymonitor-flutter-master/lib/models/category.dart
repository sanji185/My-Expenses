import 'package:flutter/material.dart';

class Category {
  String id;
  String name;
  IconData icon;
  bool show = true;
  Category(this.id, this.name, [this.icon]);

  Category.fromJson(key, value) {
    id = key;
    name = value["name"];
  }

  void updateVisibility(bool value) {
    show = value;
  }
}
