import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/catalog_models.dart';
import '../models/video_lesson.dart';
import '../repositories/video_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/comments_section.dart';
import '../widgets/custom_card.dart';
import '../widgets/media_video_player.dart';
import 'notes_pdf_page.dart';
import 'quiz_page.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage({super.key, required this.topic});

  final TopicDetail topic;

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  final _videoRepository = VideoRepository(ApiClient());
  TopicContentRef? _selectedVideo;
  Future<VideoLesson>? _videoFuture;

  @override
  void initState() {
    super.initState();
    if (widget.topic.videos.isNotEmpty) {
      _selectVideo(widget.topic.videos.first);
    }
  }

  void _selectVideo(TopicContentRef ref) {
    setState(() {
      _selectedVideo = ref;
      _videoFuture = _videoRepository.fetchVideoById(ref.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;

    return Scaffold(
      appBar: AppBar(title: Text(topic.name)),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (topic.videos.isNotEmpty) ...[
              if (_videoFuture != null)
                FutureBuilder<VideoLesson>(
                  future: _videoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      );
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      final message = snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Unable to load this video.';
                      return AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(message, style: AppTypography.bodyMedium),
                        ),
                      );
                    }
                    final video = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: MediaVideoPlayer(videoUrl: video.videoUrl),
                        ),
                        const SizedBox(height: 12),
                        Text(video.videoName, style: AppTypography.titleLarge),
                        if (video.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(video.description, style: AppTypography.bodyMedium),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Discussion & Comments',
                          style: AppTypography.titleMedium.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 320,
                          child: CommentsSection(videoId: video.id),
                        ),
                      ],
                    );
                  },
                ),
              if (topic.videos.length > 1) ...[
                const SizedBox(height: 16),
                Text('Lessons', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                ...topic.videos.map(
                  (ref) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ContentTile(
                      icon: Icons.play_arrow_rounded,
                      iconBackground: AppColors.primaryLight,
                      iconColor: AppColors.primaryDark,
                      title: ref.name,
                      selected: ref.id == _selectedVideo?.id,
                      onTap: () => _selectVideo(ref),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
            if (topic.notes.isNotEmpty) ...[
              Text('Notes', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              ...topic.notes.map(
                (ref) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContentTile(
                    icon: Icons.description_outlined,
                    iconBackground: AppColors.secondaryLight,
                    iconColor: AppColors.secondaryDark,
                    title: ref.name,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotesPdfPage(notesId: ref.id, title: ref.name),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (topic.mcqTests.isNotEmpty) ...[
              Text('MCQ Tests', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              ...topic.mcqTests.map(
                (ref) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContentTile(
                    icon: Icons.quiz_outlined,
                    iconBackground: AppColors.primaryLight,
                    iconColor: AppColors.primaryDark,
                    title: ref.name,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizPage(testId: ref.id, title: ref.name),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContentTile extends StatelessWidget {
  const _ContentTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
              border: selected ? Border.all(color: iconColor, width: 2) : null,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleMedium,
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
        ],
      ),
    );
  }
}
