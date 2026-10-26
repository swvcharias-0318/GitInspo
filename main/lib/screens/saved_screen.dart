import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String? _boardId;

  Future<String?> _boardNameDialog({String? initial}) async {
    final controller = TextEditingController(text: initial);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(initial == null ? 'New board' : 'Rename board'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 32,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Board name'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    return name?.isEmpty ?? true ? null : name;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final selected = state.boards.any((board) => board.id == _boardId) ? _boardId : null;
          final saved = state.posts.where((post) => state.savedPostBoards.containsKey(post.id) &&
              (selected == null || state.savedPostBoards[post.id] == selected)).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(21, 20, 17, 8),
                child: Row(
                  children: [
                    Expanded(child: Text('Your boards', style: Theme.of(context).textTheme.headlineMedium)),
                    IconButton.filledTonal(
                      tooltip: 'Create board',
                      onPressed: () async {
                        final name = await _boardNameDialog();
                        if (name != null && context.mounted) await context.read<AppState>().addBoard(name);
                      },
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(22, 2, 22, 15),
                child: Text('Keep the things you want to come back to.', style: TextStyle(color: AppTheme.muted)),
              ),
              SizedBox(
                height: 42,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Everything'),
                        selected: selected == null,
                        onSelected: (_) => setState(() => _boardId = null),
                        showCheckmark: false,
                        selectedColor: AppTheme.ink,
                        labelStyle: TextStyle(color: selected == null ? Colors.white : AppTheme.ink, fontSize: 12),
                      ),
                    ),
                    ...state.boards.map((board) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onLongPress: () => _showBoardMenu(context, board),
                        child: ChoiceChip(
                          label: Text(board.name),
                          selected: selected == board.id,
                          onSelected: (_) => setState(() => _boardId = board.id),
                          showCheckmark: false,
                          selectedColor: AppTheme.ink,
                          labelStyle: TextStyle(color: selected == board.id ? Colors.white : AppTheme.ink, fontSize: 12),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: saved.isEmpty
                    ? const _SavedEmptyState()
                    : MasonryGridView.count(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 12,
                        itemCount: saved.length,
                        itemBuilder: (context, index) => PostCard(
                          post: saved[index],
                          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PostDetailScreen(post: saved[index]))),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showBoardMenu(BuildContext context, InspoBoard board) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Rename board'), onTap: () => Navigator.pop(sheetContext, 'rename')),
            ListTile(leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.coral), title: const Text('Delete board'), onTap: () => Navigator.pop(sheetContext, 'delete')),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'rename') {
      final name = await _boardNameDialog(initial: board.name);
      if (name != null && context.mounted) await context.read<AppState>().renameBoard(board.id, name);
    } else {
      final state = context.read<AppState>();
      await state.deleteBoard(board.id);
      if (_boardId == board.id) setState(() => _boardId = null);
    }
  }
}

class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmarks_outlined, size: 42, color: AppTheme.muted),
          SizedBox(height: 12),
          Text('A place for your good finds', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          SizedBox(height: 5),
          Text('Save a post and it will show up here.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted)),
        ],
      ),
    ),
  );
}