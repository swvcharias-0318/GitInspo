import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String _category = 'For you';
  final _categories = const ['For you', 'Fashion', 'Food', 'Travel', 'Art', 'Room design', 'Study'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 13, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(color: AppTheme.coral, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 9),
                const Text('GitInspo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(tooltip: 'Notifications', onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                const CircleAvatar(radius: 17, backgroundColor: Color(0xFFE5C6B9), child: Text('A', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Find a little inspiration',
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: Icon(Icons.tune_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = _category == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = category),
                  showCheckmark: false,
                  backgroundColor: const Color(0xFFF2F0EB),
                  selectedColor: AppTheme.ink,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.ink, fontWeight: FontWeight.w600, fontSize: 12),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: [
                Text('Made for your mood', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                Spacer(),
                Icon(Icons.auto_awesome, size: 18, color: AppTheme.coral),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, _) {
                final posts = state.posts.where((post) {
                  final categoryMatches = _category == 'For you' || post.category.toLowerCase() == _category.toLowerCase();
                  final query = _search.text.trim().toLowerCase();
                  final queryMatches = query.isEmpty ||
                      '${post.title} ${post.description} ${post.creator} ${post.category} ${post.tags.join(' ')}'.toLowerCase().contains(query);
                  return categoryMatches && queryMatches;
                }).toList();
                if (posts.isEmpty) return const _EmptyFeed();
                return MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 18),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 12,
                  itemCount: posts.length,
                  itemBuilder: (context, index) => PostCard(
                    post: posts[index],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PostDetailScreen(post: posts[index]))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 38, color: AppTheme.muted),
          SizedBox(height: 12),
          Text('No ideas found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          SizedBox(height: 5),
          Text('Try another search or category.', style: TextStyle(color: AppTheme.muted)),
        ],
      ),
    ),
  );
}