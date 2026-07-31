import 'package:flutter/material.dart';

import '../models/video_lesson.dart';
import '../widgets/comments_section.dart';
import '../widgets/media_video_player.dart';
import '../widgets/notes_viewer.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.video,
    this.autoShowNotes = false,
  });

  final VideoLesson video;
  final bool autoShowNotes;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late bool _showNotes;

  @override
  void initState() {
    super.initState();
    _showNotes = widget.autoShowNotes;
  }

  void _toggleNotes() => setState(() => _showNotes = !_showNotes);

  void _closeNotes() => setState(() => _showNotes = false);

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

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
          // Fixed: the video itself never scrolls or shrinks away.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: video.videoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: MediaVideoPlayer(videoUrl: video.videoUrl),
                  )
                : Container(
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
          ),
          // Metadata section: hidden when notes view is active
          if (!_showNotes)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.videoName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3A1E0B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.subject} • ${video.chapter}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8F6A4D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF6F4F39),
                    ),
                  ),
                  if (video.hasNotes) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _toggleNotes,
                        icon: const Icon(Icons.description_rounded),
                        label: const Text('View Notes'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF97316),
                          side: const BorderSide(color: Color(0xFFF97316)),
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
          // Flexible: Notes and Comments take turns owning all of the
          // remaining space — opening one fully replaces the other.
          Expanded(
            child: _showNotes
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.description_rounded,
                              color: Color(0xFFF97316),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3A1E0B),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _closeNotes,
                              icon: const Icon(Icons.close_rounded),
                              color: const Color(0xFF3A1E0B),
                              tooltip: 'Close notes',
                            ),
                          ],
                        ),
                        Expanded(child: NotesViewer(notesUrl: video.notesUrl!)),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3A1E0B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(child: CommentsSection(videoId: video.id)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
