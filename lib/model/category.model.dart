import 'package:flutter/material.dart';

import '../data/icons.dart';

class Category {
  int? id;
  String name;
  int iconCode;
  int colorValue;
  double? budget;
  double? expense;

  IconData get icon => AppIcons.fromCodePoint(
        iconCode,
        fallback: Icons.wallet_outlined,
      );
  set icon(IconData value) => iconCode = value.codePoint;

  Color get color => Color(colorValue);
  set color(Color value) => colorValue = value.value;

  Category({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.budget,
    this.expense,
  });

  factory Category.fromJson(Map<String, dynamic> data) => Category(
        id: data['id'] as int?,
        name: data['name'] as String? ?? '',
        iconCode: data['icon'] as int? ?? Icons.wallet_outlined.codePoint,
        colorValue: data['color'] as int? ?? Colors.pink.value,
        budget: (data['budget'] as num?)?.toDouble() ?? 0,
        expense: (data['expense'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': iconCode,
        'color': colorValue,
        'budget': budget,
      };
}
