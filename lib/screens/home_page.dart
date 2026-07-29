import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../models/dashboard_content.dart';
import '../models/testimonial.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/testimonial_repository.dart';
import '../state/session_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/brand_title.dart';
import '../widgets/reviews_carousel.dart';
import 'courses_page.dart';
import 'subject_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final Future<DashboardContent> _dashboardFuture;
  late Future<List<Testimonial>> _testimonialsFuture;
  final _testimonialRepository = TestimonialRepository(ApiClient());

  @override
  void initState() {
    super.initState();
    _dashboardFuture = DashboardRepository().load();
    _testimonialsFuture = _testimonialRepository.fetchPublicTestimonials();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final coursesFuture = context.read<SessionState>().refreshCourses();
    final testimonialsFuture = _testimonialRepository.fetchPublicTestimonials();
    setState(() {
      _testimonialsFuture = testimonialsFuture;
    });
    await Future.wait([coursesFuture, testimonialsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<SessionState>().courses;
    final fewCourses = courses.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      body: FutureBuilder<DashboardContent>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Unable to load dashboard content.'),
              ),
            );
          }

          final content = snapshot.data!;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _SchoolBannerCard(school: content.school),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Testimonial>>(
                    future: _testimonialsFuture,
                    builder: (context, testimonialSnapshot) {
                      final testimonials = testimonialSnapshot.data ?? [];
                      if (testimonialSnapshot.connectionState !=
                              ConnectionState.done ||
                          testimonials.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Testimonials',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3A1E0B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ReviewsCarousel(testimonials: testimonials),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                  const BannerCarousel(
                    imagePaths: [
                      'assets/images/tks-banner1.jpg',
                      'assets/images/tks-banner2.jpg',
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Course',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3A1E0B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CoursesPage(),
                            ),
                          );
                        },
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...fewCourses.map((course) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFDDBF)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        title: Text(
                          course.courseName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3A1E0B),
                          ),
                        ),
                        subtitle: Text(
                          '${course.subjects.length} subjects • ${course.chapterCount} chapters',
                        ),
                        trailing: const Icon(Icons.arrow_forward_rounded),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SubjectPage(course: course),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SchoolBannerCard extends StatelessWidget {
  const _SchoolBannerCard({required this.school});

  final SchoolProfile school;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFFFDAA5D), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const AppLogo(size: 84),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrandTitle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    school.location,
                    style: const TextStyle(
                      color: Color(0xFFFDEEE2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
