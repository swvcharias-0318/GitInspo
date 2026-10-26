import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onTap});

  final InspoPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<AppState, bool>((state) => state.savedPostBoards.containsKey(post.id));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  SizedBox(width: double.infinity, height: post.height, child: PostImage(post: post)),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: _RoundAction(
                      icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      selected: saved,
                      tooltip: saved ? 'Remove from saved' : 'Save to a board',
                      onPressed: () => savePostToBoard(context, post),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.25)),
            const SizedBox(height: 4),
            Text('@${post.creator}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }
}

class PostImage extends StatelessWidget {
  const PostImage({super.key, required this.post});

  final InspoPost post;

  @override
  Widget build(BuildContext context) {
    if (post.imageBytes != null) {
      return Image.memory(post.imageBytes!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const _ImageFallback());
    }
    if (post.imageUrl.isEmpty) return const _ImageFallback();
    return Image.network(
      post.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: const Color(0xFFEAE7E1),
              alignment: Alignment.center,
              child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.coral)),
            ),
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFECE9E2),
    alignment: Alignment.center,
    child: const Icon(Icons.image_outlined, color: AppTheme.muted, size: 30),
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.selected, required this.tooltip, required this.onPressed});

  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.94),
    shape: const CircleBorder(),
    child: IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(icon, key: ValueKey(selected), size: 19, color: selected ? AppTheme.coral : AppTheme.ink),
      ),
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    ),
  );
}

Future<void> savePostToBoard(BuildContext context, InspoPost post) async {
  final state = context.read<AppState>();
  if (state.savedPostBoards.containsKey(post.id)) {
    await state.toggleSave(post);
    return;
  }
  if (state.boards.isEmpty) {
    await state.addBoard('My ideas');
  }
  if (!context.mounted) return;
  final selectedId = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Save to a board', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...state.boards.map((board) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(board.name),
              onTap: () => Navigator.pop(sheetContext, board.id),
            )),
          ],
        ),
      ),
    ),
  );
  if (selectedId != null && context.mounted) {
    await state.toggleSave(post, boardId: selectedId);
  }
}