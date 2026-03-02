import 'package:flutter/material.dart';

class AppIcons {
  static final List<IconData> icons = [
    Icons.wallet,
    Icons.money,
    Icons.account_balance,
    Icons.shopping_bag,
    Icons.fastfood,
    Icons.handshake,
    Icons.public,
    Icons.thumb_up,
    Icons.face,
    Icons.rocket_launch,
    Icons.eco,
    Icons.pets,
    Icons.emoji_objects,
    Icons.health_and_safety,
    Icons.monitor_heart,
    Icons.gavel,
    Icons.diversity_3,
    Icons.workspaces,
    Icons.cookie,
    Icons.emoji_flags,
    Icons.hive,
    Icons.heart_broken,
    Icons.medication_liquid,
    Icons.shopping_cart,
    Icons.landscape,
    Icons.medication,
    Icons.verified,
    Icons.lock,
    Icons.celebration,
    Icons.stars,
    Icons.developer_mode,
    Icons.person,
    Icons.bar_chart,
    Icons.domain,
    Icons.leaderboard,
    Icons.work,
    Icons.credit_card,
    Icons.loyalty,
    Icons.card_membership,
    Icons.pallet,
    Icons.restaurant,
    Icons.restaurant_menu,
    Icons.join_full,
  ];

  static final Map<int, IconData> _iconByCodePoint = {
    for (final icon in icons) icon.codePoint: icon,
    Icons.account_circle.codePoint: Icons.account_circle,
    Icons.wallet_outlined.codePoint: Icons.wallet_outlined,
    Icons.house.codePoint: Icons.house,
    Icons.emoji_transportation.codePoint: Icons.emoji_transportation,
    Icons.category.codePoint: Icons.category,
    Icons.medical_information.codePoint: Icons.medical_information,
    Icons.attach_money.codePoint: Icons.attach_money,
    Icons.tv.codePoint: Icons.tv,
    Icons.library_books_sharp.codePoint: Icons.library_books_sharp,
  };

  static IconData fromCodePoint(int codePoint, {required IconData fallback}) {
    return _iconByCodePoint[codePoint] ?? fallback;
  }
}
