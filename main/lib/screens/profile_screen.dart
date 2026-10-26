import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/post_card.dart';
import 'login_screen.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context, AppState state) async {
    final username = TextEditingController(text: state.username);
    final bio = TextEditingController(text: state.bio);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: username, decoration: const InputDecoration(labelText: 'Username', prefixText: '@ ')),
            const SizedBox(height: 13),
            TextField(controller: bio, maxLines: 3, maxLength: 100, decoration: const InputDecoration(labelText: 'Bio')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved == true && context.mounted && username.text.trim().isNotEmpty) {
      await state.updateProfile(handle: username.text.trim().replaceFirst('@', ''), about: bio.text.trim());
    }
    username.dispose();
    bio.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final ownPosts = state.posts.where((post) => post.creator == state.username).toList();
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(21, 18, 17, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: Text('Your space', style: Theme.of(context).textTheme.headlineMedium)),
                      IconButton(tooltip: 'Sign out', onPressed: () async {
                        await state.logout();
                        if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const LoginScreen()), (_) => false);
                      }, icon: const Icon(Icons.logout_rounded)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 17, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 43,
                        backgroundColor: Color(0xFFE7C9BE),
                        child: Icon(Icons.person_rounded, size: 43, color: AppTheme.ink),
                      ),
                      const SizedBox(height: 12),
                      Text(state.fullName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text('@${state.username}', style: const TextStyle(color: AppTheme.muted)),
                      const SizedBox(height: 9),
                      Text(state.bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 19),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Stat(value: '${ownPosts.length}', label: 'Posts'),
                          const _StatDivider(),
                          const _Stat(value: '128', label: 'Followers'),
                          const _StatDivider(),
                          const _Stat(value: '84', label: 'Following'),
                        ],
                      ),
                      const SizedBox(height: 17),
                      SizedBox(
                        height: 43,
                        child: OutlinedButton.icon(
                          onPressed: () => _editProfile(context, state),
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text('Edit profile'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(21, 27, 21, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(child: Text('Your boards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                      Text('${state.boards.length}', style: const TextStyle(color: AppTheme.muted)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 112,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.boards.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 11),
                    itemBuilder: (context, index) => _BoardPreview(
                      board: state.boards[index],
                      count: state.savedPostBoards.values.where((id) => id == state.boards[index].id).length,
                      posts: state.posts.where((post) => state.savedPostBoards[post.id] == state.boards[index].id).take(3).toList(),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(21, 26, 21, 13),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(child: Text('Your posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                      Text('${ownPosts.length}', style: const TextStyle(color: AppTheme.muted)),
                    ],
                  ),
                ),
              ),
              if (ownPosts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, 35),
                    child: Center(child: Text('Your shared ideas will live here.', style: TextStyle(color: AppTheme.muted))),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 12,
                    childCount: ownPosts.length,
                    itemBuilder: (context, index) => PostCard(
                      post: ownPosts[index],
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PostDetailScreen(post: ownPosts[index]))),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 85,
    child: Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
      ],
    ),
  );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 25, color: const Color(0xFFE8E5DF));
}

class _BoardPreview extends StatelessWidget {
  const _BoardPreview({required this.board, required this.count, required this.posts});
  final InspoBoard board;
  final int count;
  final List<InspoPost> posts;

  @override
  Widget build(BuildContext context) => Container(
    width: 175,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: const Color(0xFFF2F0EB), borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          height: 88,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: posts.isEmpty
                ? const ColoredBox(color: Color(0xFFE6E1D8), child: Icon(Icons.dashboard_outlined, color: AppTheme.muted))
                : PostImage(post: posts.first),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(board.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('$count saved', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ],
          ),
        ),
      ],
    ),
  );
}