import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.post});

  final InspoPost post;

  @override
  Widget build(BuildContext context) {
    final liked = context.select<AppState, bool>((state) => state.likedPosts.contains(post.id));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 430,
            backgroundColor: AppTheme.paper,
            leading: Padding(
              padding: const EdgeInsets.all(7),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.94),
                child: IconButton(tooltip: 'Back', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, size: 20)),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'post-${post.id}',
                child: SizedBox.expand(child: PostImage(post: post)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(post.title, style: Theme.of(context).textTheme.headlineMedium)),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => savePostToBoard(context, post),
                        style: FilledButton.styleFrom(backgroundColor: AppTheme.coral, padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13)),
                        child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const CircleAvatar(radius: 19, backgroundColor: Color(0xFFE6C9BD), child: Icon(Icons.person_rounded, color: AppTheme.ink, size: 20)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@${post.creator}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(post.category, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: liked ? 'Unlike' : 'Like',
                        onPressed: () => context.read<AppState>().toggleLike(post),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, key: ValueKey(liked), color: liked ? AppTheme.coral : AppTheme.ink),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Share post',
                        onPressed: () => SharePlus.instance.share(ShareParams(text: '${post.title}\n${post.description}')),
                        icon: const Icon(Icons.ios_share_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(post.description, style: const TextStyle(fontSize: 15, height: 1.55)),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags.map((tag) => Chip(
                        label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFFF2F0EB),
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}