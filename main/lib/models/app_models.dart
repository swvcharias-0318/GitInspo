import 'dart:typed_data';

class InspoPost {
  const InspoPost({
    required this.id,
    required this.title,
    required this.creator,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.height,
    this.tags = const [],
    this.imageBytes,
  });

  final String id;
  final String title;
  final String creator;
  final String category;
  final String imageUrl;
  final String description;
  final double height;
  final List<String> tags;
  final Uint8List? imageBytes;

  InspoPost copyWith({String? imageUrl, Uint8List? imageBytes}) => InspoPost(
    id: id,
    title: title,
    creator: creator,
    category: category,
    imageUrl: imageUrl ?? this.imageUrl,
    description: description,
    height: height,
    tags: tags,
    imageBytes: imageBytes ?? this.imageBytes,
  );

  factory InspoPost.fromMap(String id, Map<String, dynamic> data) => InspoPost(
    id: id,
    title: data['title'] as String? ?? 'Untitled idea',
    creator: data['username'] as String? ?? 'creator',
    category: data['category'] as String? ?? 'Inspiration',
    imageUrl: data['imageUrl'] as String? ?? '',
    description: data['description'] as String? ?? '',
    height: (data['height'] as num?)?.toDouble() ?? 245,
    tags: (data['tags'] as List<dynamic>? ?? []).cast<String>(),
  );
}

class InspoBoard {
  const InspoBoard({required this.id, required this.name, this.description = ''});

  final String id;
  final String name;
  final String description;
}

const demoPosts = <InspoPost>[
  InspoPost(
    id: 'p1',
    title: 'A slower kind of morning',
    creator: 'mila.makes',
    category: 'Room design',
    imageUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&auto=format&fit=crop&q=85',
    description: 'Soft light, tactile linen, and a little room to breathe.',
    height: 286,
    tags: ['interiors', 'slow living'],
  ),
  InspoPost(
    id: 'p2',
    title: 'Market flowers, just because',
    creator: 'oliviarose',
    category: 'Art',
    imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&auto=format&fit=crop&q=85',
    description: 'An imperfect bunch of seasonal flowers for the kitchen table.',
    height: 220,
    tags: ['flowers', 'color'],
  ),
  InspoPost(
    id: 'p3',
    title: 'Sunday pasta ritual',
    creator: 'thelittlekitchen',
    category: 'Food',
    imageUrl: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=800&auto=format&fit=crop&q=85',
    description: 'A simple bowl of handmade pasta with basil and parmesan.',
    height: 225,
    tags: ['recipe', 'pasta'],
  ),
  InspoPost(
    id: 'p4',
    title: 'Coastal lines in Copenhagen',
    creator: 'joandjourney',
    category: 'Travel',
    imageUrl: 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=800&auto=format&fit=crop&q=85',
    description: 'A quiet afternoon wandering through narrow old-town streets.',
    height: 300,
    tags: ['travel', 'architecture'],
  ),
  InspoPost(
    id: 'p5',
    title: 'The art of getting dressed',
    creator: 'wearwithmay',
    category: 'Fashion',
    imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=85',
    description: 'A thoughtful, wearable palette in warm neutrals and soft denim.',
    height: 260,
    tags: ['style', 'wardrobe'],
  ),
  InspoPost(
    id: 'p6',
    title: 'A corner made for reading',
    creator: 'houseofjune',
    category: 'Room design',
    imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800&auto=format&fit=crop&q=85',
    description: 'A favorite chair, a good lamp, and no plans for the evening.',
    height: 235,
    tags: ['interiors', 'reading'],
  ),
  InspoPost(
    id: 'p7',
    title: 'A little color study',
    creator: 'studio.leni',
    category: 'Art',
    imageUrl: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800&auto=format&fit=crop&q=85',
    description: 'Loose shapes and unexpected colors from a sketchbook afternoon.',
    height: 250,
    tags: ['painting', 'creative'],
  ),
  InspoPost(
    id: 'p8',
    title: 'Golden hour, somewhere new',
    creator: 'luciawanders',
    category: 'Travel',
    imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&auto=format&fit=crop&q=85',
    description: 'The kind of view that makes you forget to check your phone.',
    height: 215,
    tags: ['travel', 'summer'],
  ),
];