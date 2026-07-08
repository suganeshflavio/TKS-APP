import 'package:flutter/material.dart';

import '../models/dashboard_content.dart';
import '../widgets/youtube_video_player.dart';

class TopicVideoPage extends StatelessWidget {
  const TopicVideoPage({
    super.key,
    required this.topic,
    required this.chapterTitle,
  });

  final TopicItem topic;
  final String chapterTitle;

  @override
  Widget build(BuildContext context) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: YoutubeVideoPlayer(videoId: topic.youtubeId),
          ),
          const SizedBox(height: 16),
          Text(
            topic.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A1E0B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$chapterTitle • ${topic.duration}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF8F6A4D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            topic.summary,
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
