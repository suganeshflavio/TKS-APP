import 'package:flutter/material.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class AppState extends ChangeNotifier {
  AppState({CourseRepository? repository})
    : _repository = repository ?? CourseRepository();

  final CourseRepository _repository;

  bool _isLoading = true;
  int _selectedCategoryIndex = 0;
  RangeValues _priceRange = const RangeValues(0, 200);
  final List<String> _selectedCategories = [];
  final List<double> _selectedRatings = [];
  List<Course> _searchResults = [];

  List<CourseCategory> _categories = [];
  List<Course> _trendingCourses = [];
  List<Course> _newReleases = [];
  List<Course> _allCourses = [];

  bool get isLoading => _isLoading;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  RangeValues get priceRange => _priceRange;
  List<String> get selectedCategories => List.unmodifiable(_selectedCategories);
  List<double> get selectedRatings => List.unmodifiable(_selectedRatings);
  List<CourseCategory> get categories => List.unmodifiable(_categories);
  List<Course> get trendingCourses => List.unmodifiable(_trendingCourses);
  List<Course> get newReleases => List.unmodifiable(_newReleases);
  List<Course> get allCourses => List.unmodifiable(_allCourses);
  List<Course> get searchResults => List.unmodifiable(_searchResults);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _repository.fetchCategories();
    _trendingCourses = await _repository.fetchTrendingCourses();
    _newReleases = await _repository.fetchNewReleases();
    _allCourses = await _repository.fetchAllCourses();

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedCategoryIndex(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchResults = await _repository.searchCourses(query);
    notifyListeners();
  }

  void setPriceRange(RangeValues values) {
    _priceRange = values;
    notifyListeners();
  }

  void toggleCategoryFilter(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void toggleRatingFilter(double rating) {
    if (_selectedRatings.contains(rating)) {
      _selectedRatings.remove(rating);
    } else {
      _selectedRatings.add(rating);
    }
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategories.clear();
    _selectedRatings.clear();
    _priceRange = const RangeValues(0, 200);
    notifyListeners();
  }
}
