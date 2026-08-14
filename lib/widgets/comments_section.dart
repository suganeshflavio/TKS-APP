import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/comment.dart';
import '../repositories/comment_repository.dart';
import 'custom_card.dart';
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
    final safeBottomInset = MediaQuery.of(context).padding.bottom;

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
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _retry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return Center(
                  child: Text(
                    'No comments yet. Be the first to start the discussion!',
                    style: AppTypography.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                itemCount: comments.length,
                padding: const EdgeInsets.only(bottom: 12),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _CommentTile(comment: comments[index]),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 8,
            bottom: safeBottomInset > 0 ? safeBottomInset : 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _isPosting ? null : _postComment(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Add a comment...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.primaryShadow,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _isPosting ? null : _postComment,
                  color: Colors.white,
                  icon: _isPosting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
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
      padding: EdgeInsets.only(left: depth * 24.0, bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.authorName,
                  style: AppTypography.titleMedium.copyWith(fontSize: 14),
                ),
                if (comment.createdAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(comment.createdAt!),
                    style: AppTypography.labelSmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              comment.message,
              style: AppTypography.bodyMedium,
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
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}
