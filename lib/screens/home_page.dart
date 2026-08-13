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
import '../widgets/skeleton.dart';
import 'courses_page.dart';
import 'subject_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late Future<DashboardContent> _dashboardFuture;
  late Future<List<Testimonial>> _testimonialsFuture;
  final _testimonialRepository = TestimonialRepository(ApiClient());
  bool _isRefreshing = false;

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
    final dashboardFuture = DashboardRepository().load();
    final testimonialsFuture = _testimonialRepository.fetchPublicTestimonials();
    final coursesFuture = context.read<SessionState>().refreshCourses();

    setState(() {
      _isRefreshing = true;
      _dashboardFuture = dashboardFuture;
      _testimonialsFuture = testimonialsFuture;
    });

    try {
      await Future.wait([
        dashboardFuture.catchError(
          (_) => const DashboardContent(
            school: SchoolProfile(name: '', location: ''),
            resources: [],
            tests: [],
            progress: [],
            videos: [],
            courses: [],
          ),
        ),
        testimonialsFuture.catchError((_) => <Testimonial>[]),
        coursesFuture.catchError((_) {}),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final courses = session.courses;
    final isLoadingCourses = session.isLoadingCourses;
    final fewCourses = courses.take(2).toList();
    final username = session.user?.name.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF3A1E0B)),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 28),
            SizedBox(width: 8),
            Text(
              'TKS Academy',
              style: TextStyle(
                color: Color(0xFF3A1E0B),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: const Color(0xFF3A1E0B),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFF6EE),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDAA5D), Color(0xFFF97316)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(size: 62),
                    const SizedBox(height: 12),
                    BrandTitle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_rounded),
                      title: const Text('Home'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.menu_book_rounded),
                      title: const Text('Courses'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CoursesPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_reset_rounded),
                      title: const Text('Forgot Password'),
                      enabled: false,
                      onTap: null,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Text(
                  '© 2026 TKS Academy',
                  style: TextStyle(color: Color(0xFF8F6A4D), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<DashboardContent>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (_isRefreshing ||
              snapshot.connectionState != ConnectionState.done) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: const DashboardSkeleton(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Unable to load dashboard content.'),
                      ),
                    ),
                  ],
                ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Hi $username',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3A1E0B),
                      ),
                    ),
                  ),
                  const BannerCarousel(
                    imagePaths: [
                      'assets/images/tks-banner1.jpg',
                      'assets/images/tks-banner2.jpg',
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isLoadingCourses)
                    const CourseSectionSkeleton()
                  else if (courses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          'No courses found.',
                          style: TextStyle(color: Color(0xFF6E4D37)),
                        ),
                      ),
                    )
                  else ...[
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
                  const SizedBox(height: 20),
                  FutureBuilder<List<Testimonial>>(
                    future: _testimonialsFuture,
                    builder: (context, testimonialSnapshot) {
                      if (testimonialSnapshot.connectionState !=
                          ConnectionState.done) {
                        return const TestimonialSectionSkeleton();
                      }
                      final testimonials = testimonialSnapshot.data ?? [];
                      if (testimonials.isEmpty) {
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
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
