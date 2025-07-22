class User {
  final int id;
  final String nickname;
  final String? profileImage;
  final String? email;
  final String? appEmail;
  final String? appNickname;
  final String provider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  User({
    required this.id,
    required this.nickname,
    this.profileImage,
    this.email,
    this.appEmail,
    this.appNickname,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nickname: json['nickname']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      email: json['email']?.toString(),
      appEmail: json['app_email']?.toString(),
      appNickname: json['app_nickname']?.toString(),
      provider: json['provider']?.toString() ?? 'unknown',
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active'] == true,
    );
  }
}

class Post {
  final int id;
  final String title;
  final String content;
  final String category;
  final List<String>? images;
  final int viewCount;
  final int authorId;
  final User author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isFavorited;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.images,
    required this.viewCount,
    required this.authorId,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      viewCount: json['view_count'] is int
          ? json['view_count']
          : int.tryParse(json['view_count']?.toString() ?? '0') ?? 0,
      authorId: json['author_id'] is int
          ? json['author_id']
          : int.tryParse(json['author_id']?.toString() ?? '0') ?? 0,
      author: User.fromJson(json['author']),
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      likeCount: json['like_count'] is int
          ? json['like_count']
          : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      commentCount: json['comment_count'] is int
          ? json['comment_count']
          : int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] is bool
          ? json['is_liked']
          : json['is_liked'] == true,
      isFavorited: json['is_favorited'] is bool
          ? json['is_favorited']
          : json['is_favorited'] == true,
    );
  }

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    List<String>? images,
    int? viewCount,
    int? authorId,
    User? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isFavorited,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      images: images ?? this.images,
      viewCount: viewCount ?? this.viewCount,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}

class Comment {
  final int id;
  final String content;
  final int postId;
  final int authorId;
  final User author;
  final int? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> replies;
  final int likeCount;
  final bool isLiked;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.authorId,
    required this.author,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? '',
      postId: json['post_id'] is int
          ? json['post_id']
          : int.tryParse(json['post_id']?.toString() ?? '0') ?? 0,
      authorId: json['author_id'] is int
          ? json['author_id']
          : int.tryParse(json['author_id']?.toString() ?? '0') ?? 0,
      author: User.fromJson(json['author']),
      parentId: json['parent_id'] is int
          ? json['parent_id']
          : (json['parent_id'] != null
                ? int.tryParse(json['parent_id'].toString())
                : null),
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      replies: json['replies'] != null
          ? (json['replies'] as List)
                .map((reply) => Comment.fromJson(reply))
                .toList()
          : [],
      likeCount: json['like_count'] is int
          ? json['like_count']
          : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] is bool
          ? json['is_liked']
          : json['is_liked'] == true,
    );
  }

  Comment copyWith({
    int? id,
    String? content,
    int? postId,
    int? authorId,
    User? author,
    int? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? replies,
    int? likeCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int size;
  final bool hasNext;
  final bool hasPrev;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List).map((item) => fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      size: json['size'],
      hasNext: json['has_next'],
      hasPrev: json['has_prev'],
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}
