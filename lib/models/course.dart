import 'package:flutter/material.dart';

class CourseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const CourseCategory(this.name, this.icon, this.color);
}

class Course {
  final String title;
  final String category;
  final double rating;
  final double price;
  final String image;
  final int? students;
  final int? hours;
  final bool isNew;

  const Course({
    required this.title,
    required this.category,
    required this.rating,
    required this.price,
    required this.image,
    this.students,
    this.hours,
    this.isNew = false,
  });
}
