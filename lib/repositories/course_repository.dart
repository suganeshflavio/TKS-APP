import 'package:flutter/material.dart';

import '../models/course.dart';

class CourseRepository {
  Future<List<CourseCategory>> fetchCategories() async {
    return const [
      CourseCategory('Business', Icons.business_rounded, Color(0xFFFFA500)),
      CourseCategory('Science', Icons.science_rounded, Color(0xFF6366F1)),
      CourseCategory('Design', Icons.palette_rounded, Color(0xFFEC4899)),
      CourseCategory('Development', Icons.code_rounded, Color(0xFF10B981)),
      CourseCategory('Marketing', Icons.trending_up_rounded, Color(0xFFF59E0B)),
    ];
  }

  Future<List<Course>> fetchTrendingCourses() async {
    return const [
      Course(
        title: 'Learning Blender & 3D Max for...',
        category: 'Design',
        rating: 4.8,
        price: 149.99,
        image: '🎨',
      ),
      Course(
        title: 'Learning Python',
        category: 'Development',
        rating: 4.9,
        price: 129.99,
        image: '🐍',
      ),
    ];
  }

  Future<List<Course>> fetchNewReleases() async {
    return const [
      Course(
        title: 'Master Web Design & Web...',
        category: 'Design',
        rating: 4.7,
        price: 99.99,
        image: '🌐',
        isNew: true,
      ),
      Course(
        title: 'Introduction to Game Development',
        category: 'Development',
        rating: 4.6,
        price: 119.99,
        image: '🎮',
        isNew: true,
      ),
      Course(
        title: 'The Complete iPhone App...',
        category: 'Development',
        rating: 4.5,
        price: 139.99,
        image: '📱',
        isNew: true,
      ),
    ];
  }

  Future<List<Course>> fetchAllCourses() async {
    return const [
      Course(
        title: 'UI/UX Design Masterclass',
        category: 'Design',
        rating: 4.8,
        price: 99.99,
        image: '🎨',
        students: 2500,
        hours: 25,
      ),
      Course(
        title: 'Advanced JavaScript',
        category: 'Development',
        rating: 4.9,
        price: 129.99,
        image: '💻',
        students: 3200,
        hours: 35,
      ),
      Course(
        title: 'Digital Marketing Pro',
        category: 'Marketing',
        rating: 4.7,
        price: 89.99,
        image: '📊',
        students: 1800,
        hours: 20,
      ),
      Course(
        title: 'Business Strategy 101',
        category: 'Business',
        rating: 4.6,
        price: 79.99,
        image: '💼',
        students: 1500,
        hours: 15,
      ),
    ];
  }

  Future<List<Course>> searchCourses(String query) async {
    final all = await fetchAllCourses();
    if (query.trim().isEmpty) {
      return const [];
    }
    final q = query.toLowerCase();
    return all.where((course) {
      return course.title.toLowerCase().contains(q) ||
          course.category.toLowerCase().contains(q);
    }).toList();
  }
}
