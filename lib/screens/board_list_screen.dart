import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:async';
import '../services/board_service.dart';
import '../models/board_models.dart';
import '../globals.dart';
import '../utils/token_utils.dart';
import 'board_detail_screen.dart';
import 'board_create_screen.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({Key? key}) : super(key: key);

  @override
  _BoardListScreenState createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final List<Post> _posts = [];
  final List<Category> _categories = [];
  late TabController _categoryTabController;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _selectedCategory;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 초기 로그인 상태 설정
    _isLoggedIn = Globals.isLoggedIn();
    print('Board - Initial login status: $_isLoggedIn'); // 디버깅용

    // 로그인 상태 변경 콜백 등록
    Globals.addLoginStateCallback(_onLoginStateChanged);

    _loadCategories();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  // 로그인 상태 변경 콜백
  void _onLoginStateChanged(bool isLoggedIn) {
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
      print('Board - Login state changed to: $_isLoggedIn'); // 디버깅용
    }
  }

  @override
  void dispose() {
    // 로그인 상태 변경 콜백 제거
    Globals.removeLoginStateCallback(_onLoginStateChanged);
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _categoryTabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await BoardService.getCategories();
      setState(() {
        _categories.clear();
        _categories.addAll(
          categoriesData.map((json) => Category.fromJson(json)),
        );
      });

      // 카테고리 로드 후 탭 컨트롤러 초기화
      if (_categories.isNotEmpty) {
        _categoryTabController = TabController(
          length: _categories.length + 1, // 전체 + 카테고리들
          vsync: this,
        );
        _categoryTabController.addListener(() {
          if (!_categoryTabController.indexIsChanging) {
            _onCategoryTabChanged();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('카테고리 로드 실패: $e')));
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (refresh) {
        _currentPage = 1;
        _posts.clear();
      }

      final response = await BoardService.getPosts(
        page: _currentPage,
        size: 10,
        category: _selectedCategory,
      );

      final paginatedResponse = PaginatedResponse<Post>.fromJson(
        response,
        (json) => Post.fromJson(json),
      );

      setState(() {
        if (refresh) {
          _posts.clear();
        }
        _posts.addAll(paginatedResponse.items);
        _hasMore = paginatedResponse.hasNext;
        _totalPages = (paginatedResponse.total / 10).ceil();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('게시글 로드 실패: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _currentPage++;
    });

    await _loadPosts();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadPosts(refresh: true);
  }

  void _onCategoryTabChanged() {
    final index = _categoryTabController.index;
    String? category;
    if (index > 0) {
      category = _categories[index - 1].id;
    }
    _onCategoryChanged(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BoardCreateScreen(),
                  ),
                );

                if (result == true) {
                  // 새 게시글이 생성되면 목록 새로고침
                  _loadPosts(refresh: true);
                }
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // 카테고리 탭
          if (_categories.isNotEmpty) ...[
            Theme(
              data: Theme.of(context).copyWith(
                tabBarTheme: const TabBarThemeData(
                  tabAlignment: TabAlignment.start,
                ),
              ),
              child: SizedBox(
                height: 44,
                child: TabBar(
                  controller: _categoryTabController,
                  isScrollable: true,
                  indicatorColor: const Color(0xFFE91E63),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade400,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  tabs: [
                    const Tab(text: '전체'),
                    ..._categories
                        .map((category) => Tab(text: category.name))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],

          // 게시글 목록
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadPosts(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }

                  final post = _posts[index];
                  return PostCard(
                    post: post,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BoardDetailScreen(postId: post.id),
                        ),
                      ).then((_) {
                        // 상세 화면에서 돌아오면 목록 새로고침
                        _loadPosts(refresh: true);
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({Key? key, required this.post, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = post.images != null && post.images!.isNotEmpty;
    final firstImage = hasImage ? post.images!.first : null;
    final imageCount = hasImage ? post.images!.length : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 메인 콘텐츠
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽: 텍스트 내용
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // 내용
                        if (post.content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            post.content,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 간격
                  if (hasImage) const SizedBox(width: 12),

                  // 오른쪽: 이미지 (있는 경우에만)
                  if (hasImage)
                    SizedBox(
                      width: 80,
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: firstImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                httpHeaders: {
                                  'User-Agent':
                                      'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1',
                                  'Accept':
                                      'image/webp,image/apng,image/*,*/*;q=0.8',
                                  'Accept-Language': 'ko-KR,ko;q=0.9,en;q=0.8',
                                  'Cache-Control': 'no-cache',
                                },
                                maxWidthDiskCache: 300,
                                maxHeightDiskCache: 300,
                                memCacheWidth: 300,
                                memCacheHeight: 300,
                                fadeInDuration: const Duration(
                                  milliseconds: 200,
                                ),
                                fadeOutDuration: const Duration(
                                  milliseconds: 200,
                                ),
                              ),
                            ),
                          ),

                          // 이미지 개수 표시 (2개 이상일 때)
                          if (imageCount > 1)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$imageCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // 하단: 정보 라인 (완전히 정렬됨)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: 분실, 시간, 조회수
                  Row(
                    children: [
                      // 카테고리 작은 배지
                      if (post.category.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(post.category),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryName(post.category),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _formatDate(post.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '조회 ${post.viewCount}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                  // 오른쪽: 댓글 수 (항상 표시)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'lost':
        return '분실';
      case 'walk':
        return '산책';
      case 'exercise':
        return '운동';
      case 'health':
        return '건강';
      case 'food':
        return '음식';
      case 'training':
        return '훈련';
      case 'grooming':
        return '미용';
      case 'general':
        return '일반';
      default:
        return categoryId;
    }
  }

  Color _getCategoryColor(String categoryId) {
    return Colors.grey[300]!;
  }
}

class FavoritePostsScreen extends StatefulWidget {
  const FavoritePostsScreen({Key? key}) : super(key: key);

  @override
  _FavoritePostsScreenState createState() => _FavoritePostsScreenState();
}

class _FavoritePostsScreenState extends State<FavoritePostsScreen> {
  final List<Post> _favoritePosts = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadFavoritePosts();
  }

  Future<void> _loadFavoritePosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await BoardService.getFavoritePosts(
        page: _currentPage,
        size: 10,
      );

      final paginatedResponse = PaginatedResponse<Post>.fromJson(
        response,
        (json) => Post.fromJson(json),
      );

      setState(() {
        _favoritePosts.addAll(paginatedResponse.items);
        _hasMore = paginatedResponse.hasNext;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('즐겨찾기 로드 실패: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _favoritePosts.isEmpty && !_isLoading
          ? const Center(child: Text('즐겨찾기한 게시글이 없습니다.'))
          : ListView.builder(
              itemCount: _favoritePosts.length,
              itemBuilder: (context, index) {
                final post = _favoritePosts[index];
                return PostCard(
                  post: post,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BoardDetailScreen(postId: post.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
