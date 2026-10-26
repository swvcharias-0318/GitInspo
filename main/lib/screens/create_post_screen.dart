import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.onCreated});

  final VoidCallback onCreated;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();
  final _picker = ImagePicker();
  final _categories = const ['Fashion', 'Food', 'Travel', 'Art', 'Hairstyles', 'Room design', 'Study ideas'];
  String _category = 'Art';
  String? _boardId;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 88, maxWidth: 1800);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() { _imageFile = image; _imageBytes = bytes; });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open gallery: $error')));
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose an image to continue.')));
      return;
    }
    final state = context.read<AppState>();
    setState(() => _saving = true);
    try {
      await state.addPost(
        title: _title.text.trim(),
        description: _description.text.trim(),
        category: _category,
        boardId: _boardId ?? (state.boards.isEmpty ? '' : state.boards.first.id),
        tags: _tags.text.split(',').map((tag) => tag.trim().replaceFirst('#', '')).where((tag) => tag.isNotEmpty).toList(),
        imageBytes: _imageBytes!,
        imageFile: _imageFile,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your idea is ready to explore.')));
      widget.onCreated();
      _formKey.currentState!.reset();
      _title.clear();
      _description.clear();
      _tags.clear();
      setState(() { _imageFile = null; _imageBytes = null; _category = 'Art'; _boardId = null; });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not publish: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boards = context.watch<AppState>().boards;
    _boardId ??= boards.isEmpty ? null : boards.first.id;
    return SafeArea(
      child: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 19, 22, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: Text('Share an idea', style: Theme.of(context).textTheme.headlineMedium)),
                    FilledButton(
                      onPressed: _saving ? null : _publish,
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.coral),
                      child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Publish'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 235,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: const Color(0xFFF0EEE8), borderRadius: BorderRadius.circular(20)),
                        child: _imageBytes == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: AppTheme.coral, size: 35),
                                  SizedBox(height: 10),
                                  Text('Choose an image', style: TextStyle(fontWeight: FontWeight.w700)),
                                  SizedBox(height: 4),
                                  Text('Tap to open your gallery', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(_imageBytes!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton.filledTonal(onPressed: _pickImage, tooltip: 'Change image', icon: const Icon(Icons.edit_outlined)),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    _fieldLabel('Title'),
                    TextFormField(
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Give this idea a name'),
                      validator: (value) => (value?.trim().isEmpty ?? true) ? 'Add a title' : null,
                    ),
                    const SizedBox(height: 17),
                    _fieldLabel('Description'),
                    TextFormField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'What makes it worth saving?'),
                      validator: (value) => (value?.trim().isEmpty ?? true) ? 'Add a short description' : null,
                    ),
                    const SizedBox(height: 17),
                    _fieldLabel('Category'),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                      onChanged: (value) => setState(() => _category = value ?? _category),
                      decoration: const InputDecoration(),
                    ),
                    const SizedBox(height: 17),
                    _fieldLabel('Board'),
                    DropdownButtonFormField<String>(
                      initialValue: _boardId,
                      items: boards.map((board) => DropdownMenuItem(value: board.id, child: Text(board.name))).toList(),
                      onChanged: (value) => setState(() => _boardId = value),
                      decoration: const InputDecoration(),
                    ),
                    const SizedBox(height: 17),
                    _fieldLabel('Tags'),
                    TextFormField(
                      controller: _tags,
                      decoration: const InputDecoration(hintText: 'interiors, handmade, weekend'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}