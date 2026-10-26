import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _search = TextEditingController();
  String _category = 'All';
  final _categories = const ['All', 'Fashion', 'Food', 'Travel', 'Art', 'Room design', 'Study'];

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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Explore', style: Theme.of(context).textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 13),
            child: TextField(
              controller: _search,
              autofocus: false,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search fashion, food, places...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? const Icon(Icons.tune_rounded)
                    : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)),
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
                final selected = category == _category;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = category),
                  showCheckmark: false,
                  backgroundColor: const Color(0xFFF2F0EB),
                  selectedColor: AppTheme.ink,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.ink, fontSize: 12, fontWeight: FontWeight.w600),
                  side: BorderSide.none,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 20, 8),
            child: Text(_search.text.isEmpty ? 'Picked for you' : 'Search results', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, _) {
                final query = _search.text.trim().toLowerCase();
                final matches = state.posts.where((post) {
                  final matchesQuery = query.isEmpty ||
                      '${post.title} ${post.description} ${post.creator} ${post.category} ${post.tags.join(' ')}'.toLowerCase().contains(query);
                  return matchesQuery && (_category == 'All' || post.category.toLowerCase() == _category.toLowerCase());
                }).toList();
                if (matches.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.travel_explore_rounded, size: 38, color: AppTheme.muted), SizedBox(height: 12), Text('Nothing here just yet', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Try a new keyword.', style: TextStyle(color: AppTheme.muted))],
                    ),
                  );
                }
                return MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(16, 3, 16, 18),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 12,
                  itemCount: matches.length,
                  itemBuilder: (context, index) => PostCard(
                    post: matches[index],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PostDetailScreen(post: matches[index]))),
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