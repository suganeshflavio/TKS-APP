import 'package:flutter/material.dart';

import '../models/video_lesson.dart';
import '../utils/youtube_url.dart';
import '../widgets/youtube_video_player.dart';

class VideoPlayerPage extends StatelessWidget {
  const VideoPlayerPage({super.key, required this.video});

  final VideoLesson video;

  @override
  Widget build(BuildContext context) {
    final videoId = extractYoutubeVideoId(video.youtubeUrl);
    debugPrint(
      '[VideoPlayerPage] youtubeUrl=${video.youtubeUrl} -> videoId=$videoId',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('Video'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (videoId != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: YoutubeVideoPlayer(videoId: videoId),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFDDBF)),
              ),
              child: const Text(
                'Unable to load this video.',
                style: TextStyle(color: Color(0xFF6E4D37)),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            video.videoName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A1E0B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${video.subject} • ${video.chapter}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF8F6A4D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            video.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF6F4F39),
            ),
          ),
        ],
      ),
    );
  }
}
