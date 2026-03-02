import 'package:flutter/material.dart';

class Account {
  int? id;
  String name;
  String holderName;
  String accountNumber;
  int iconCode;
  int colorValue;
  bool? isDefault;
  double? balance;
  double? income;
  double? expense;

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  set icon(IconData value) => iconCode = value.codePoint;

  Color get color => Color(colorValue);
  set color(Color value) => colorValue = value.value;

  Account({
    this.id,
    required this.name,
    required this.holderName,
    required this.accountNumber,
    required this.iconCode,
    required this.colorValue,
    this.isDefault,
    this.income,
    this.expense,
    this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> data) => Account(
    id: data['id'] as int?,
    name: data['name'] as String? ?? '',
    holderName: data['holderName'] as String? ?? '',
    accountNumber: data['accountNumber'] as String? ?? '',
    iconCode: data['icon'] as int? ?? Icons.account_circle.codePoint,
    colorValue: data['color'] as int? ?? Colors.grey.value,
    isDefault: (data['isDefault'] ?? 0) == 1,
    income: (data['income'] as num?)?.toDouble(),
    expense: (data['expense'] as num?)?.toDouble(),
    balance: (data['balance'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'holderName': holderName,
        'accountNumber': accountNumber,
        'icon': iconCode,
        'color': colorValue,
        'isDefault': (isDefault ?? false) ? 1 : 0,
      };
}
