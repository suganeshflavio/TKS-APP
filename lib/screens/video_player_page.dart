import 'package:flutter/material.dart';

import '../models/video_lesson.dart';
import '../utils/youtube_url.dart';
import '../widgets/notes_viewer.dart';
import '../widgets/youtube_video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.video});

  final VideoLesson video;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _showNotes = false;
  final _topScrollController = ScrollController();

  @override
  void dispose() {
    _topScrollController.dispose();
    super.dispose();
  }

  void _toggleNotes() {
    // Reset scroll position before the viewport resizes, otherwise a
    // stale offset can become invalid for the new (smaller) extent and
    // trip a sliver layout assertion.
    if (_topScrollController.hasClients) {
      _topScrollController.jumpTo(0);
    }
    setState(() => _showNotes = !_showNotes);
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final videoId = extractYoutubeVideoId(video.youtubeUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('Video'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: _showNotes ? 4 : 1,
            child: ListView(
              controller: _topScrollController,
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
                if (video.hasNotes) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _toggleNotes,
                      icon: Icon(
                        _showNotes
                            ? Icons.visibility_off_rounded
                            : Icons.description_rounded,
                      ),
                      label: Text(_showNotes ? 'Hide Notes' : 'View Notes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                        side: const BorderSide(color: Color(0xFFF97316)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
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
          ),
          if (_showNotes) ...[
            const Divider(height: 1, color: Color(0xFFFFDDBF)),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: NotesViewer(notesUrl: video.notesUrl!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
