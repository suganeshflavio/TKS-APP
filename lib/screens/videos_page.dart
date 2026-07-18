import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/video_lesson.dart';
import '../repositories/video_repository.dart';
import '../widgets/inline_search_field.dart';
import 'video_player_page.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.subjectName,
    required this.chapterName,
  });

  final String courseId;
  final String courseName;
  final String subjectName;
  final String chapterName;

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final _repository = VideoRepository(ApiClient());
  late Future<List<VideoLesson>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<VideoLesson>> _load() async {
    final data = await _repository.fetchVideos(
      courseId: widget.courseId,
      chapter: widget.chapterName,
    );
    final videos = data.videos.where((video) => video.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return videos;
  }

  void _retry() {
    setState(() => _future = _load());
  }

  void _openVideo(VideoLesson video) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VideoPlayerPage(video: video)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: Text(widget.chapterName),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InlineSearchField(
                hintText: 'Search videos',
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: FutureBuilder<List<VideoLesson>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      final message = snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Unable to load videos.';
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF6E4D37)),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _retry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF97316),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final videos = (snapshot.data ?? [])
                        .where(
                          (video) => video.videoName.toLowerCase().contains(
                            _query.trim().toLowerCase(),
                          ),
                        )
                        .toList();

                    if (videos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No videos found.',
                          style: TextStyle(color: Color(0xFF6E4D37)),
                        ),
                      );
                    }

                    final notedVideos = videos
                        .where((video) => video.hasNotes)
                        .toList();

                    return ListView(
                      children: [
                        ...videos.map(
                          (video) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _VideoTile(
                              video: video,
                              onTap: () => _openVideo(video),
                            ),
                          ),
                        ),
                        if (notedVideos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3A1E0B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...notedVideos.map(
                            (video) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _NoteTile(
                                video: video,
                                onTap: () => _openVideo(video),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.onTap});

  final VideoLesson video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFDDBF)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE6D2),
          child: Icon(Icons.play_arrow_rounded, color: Color(0xFFF97316)),
        ),
        title: Text(
          video.videoName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A1E0B),
          ),
        ),
        subtitle: Text(video.subject),
        trailing: const Icon(Icons.arrow_forward_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.video, required this.onTap});

  final VideoLesson video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFDDBF)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE6D2),
          child: Icon(Icons.description_rounded, color: Color(0xFFF97316)),
        ),
        title: Text(
          video.videoName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A1E0B),
          ),
        ),
        subtitle: const Text('Tap to view notes'),
        trailing: const Icon(Icons.arrow_forward_rounded),
        onTap: onTap,
      ),
    );
  }
}
