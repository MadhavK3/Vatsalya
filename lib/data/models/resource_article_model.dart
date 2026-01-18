import 'package:flutter/material.dart';

class ResourceArticleModel {
  final String id;
  final String title;
  final String description;
  final String content; // Markdown content
  final IconData icon;
  final Color color;
  final String category;
  final bool isFeatured;
  final String readingTime;

  const ResourceArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.icon,
    required this.color,
    this.category = 'General',
    this.isFeatured = false,
    this.readingTime = '3 min',
  });
}
