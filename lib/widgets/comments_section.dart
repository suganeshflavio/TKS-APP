import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/comment.dart';
import '../repositories/comment_repository.dart';
import 'skeleton.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key, required this.videoId});

  final String videoId;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _repository = CommentRepository(ApiClient());
  final _messageController = TextEditingController();
  late Future<List<Comment>> _future;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchComments(widget.videoId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() => _future = _repository.fetchComments(widget.videoId));
  }

  Future<void> _postComment() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await _repository.postComment(videoId: widget.videoId, message: message);
      _messageController.clear();
      _retry();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FutureBuilder<List<Comment>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CommentListSkeleton();
              }

              if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to load comments: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFF6E4D37)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _retry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                        side: const BorderSide(color: Color(0xFFF97316)),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return const Center(
                  child: Text(
                    'No comments yet. Be the first to comment.',
                    style: TextStyle(color: Color(0xFF8F6A4D)),
                  ),
                );
              }

              return ListView.separated(
                itemCount: comments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _CommentTile(comment: comments[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Add a comment',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: Color(0xFFFFDDBF)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _isPosting ? null : _postComment,
                  color: const Color(0xFFF97316),
                  icon: _isPosting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, this.depth = 0});

  final Comment comment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFDDBF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFFFE6D2),
                  child: Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFFF97316),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A1E0B),
                  ),
                ),
                if (comment.createdAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(comment.createdAt!),
                    style: const TextStyle(
                      color: Color(0xFF8F6A4D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              comment.message,
              style: const TextStyle(color: Color(0xFF6E4D37)),
            ),
            ...comment.replies.map(
              (reply) => _CommentTile(comment: reply, depth: depth + 1),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
