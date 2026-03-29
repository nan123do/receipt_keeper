// lib/models/menu_item_model.dart

import 'package:flutter/material.dart';

class MenuItemModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const MenuItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });
}
