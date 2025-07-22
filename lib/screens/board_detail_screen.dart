import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../services/board_service.dart';
import '../models/board_models.dart';
import '../utils/token_utils.dart';
import 'board_edit_screen.dart';

class BoardDetailScreen extends StatefulWidget {
  final int postId;

  const BoardDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _BoardDetailScreenState createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  Post? _post;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = false;
  bool _isLoggedIn = false;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int? _replyingToCommentId;
  String _commentSortOrder = 'desc'; // 기본값을 최신순(desc)으로 설정

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadPost();
    _loadComments();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // 토큰 유효성 검사
    bool isValidToken = TokenUtils.isTokenValid(token);

    print('Detail - Token: $token, isValidToken: $isValidToken'); // 디버깅용
    setState(() {
      _isLoggedIn = isValidToken;
    });
    print('Detail - Is logged in: $_isLoggedIn'); // 디버깅용
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final response = await BoardService.getPost(widget.postId);
      setState(() {
        _post = Post.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('게시글 로드 실패: $e')));
    }
  }

  Future<void> _loadComments() async {
    if (_isLoadingComments) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final response = await BoardService.getComments(
        postId: widget.postId,
        page: 1,
        size: 50,
      );

      final paginatedResponse = PaginatedResponse<Comment>.fromJson(
        response,
        (json) => Comment.fromJson(json),
      );

      setState(() {
        // 클라이언트 사이드에서 정렬 적용
        _comments = paginatedResponse.items;
        _comments.sort((a, b) {
          if (_commentSortOrder == 'desc') {
            return b.createdAt.compareTo(a.createdAt); // 최신순
          } else {
            return a.createdAt.compareTo(b.createdAt); // 등록순
          }
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 로드 실패: $e')));
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;

    // 즉시 UI 업데이트 (낙관적 업데이트)
    final currentLiked = _post!.isLiked;
    final currentLikeCount = _post!.likeCount;

    setState(() {
      _post = _post!.copyWith(
        isLiked: !currentLiked,
        likeCount: currentLiked ? currentLikeCount - 1 : currentLikeCount + 1,
      );
    });

    try {
      final response = await BoardService.toggleLike(widget.postId);
      // 서버 응답으로 최종 상태 업데이트
      setState(() {
        _post = _post!.copyWith(
          isLiked: response['liked'],
          likeCount: response['liked']
              ? currentLikeCount + 1
              : currentLikeCount - 1,
        );
      });
    } catch (e) {
      // 실패 시 원래 상태로 되돌리기
      setState(() {
        _post = _post!.copyWith(
          isLiked: currentLiked,
          likeCount: currentLikeCount,
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('좋아요 실패: $e')));
    }
  }

  Future<void> _toggleFavorite() async {
    if (_post == null) return;

    // 즉시 UI 업데이트 (낙관적 업데이트)
    final currentFavorited = _post!.isFavorited;

    setState(() {
      _post = _post!.copyWith(isFavorited: !currentFavorited);
    });

    try {
      final response = await BoardService.toggleFavorite(widget.postId);
      // 서버 응답으로 최종 상태 업데이트
      setState(() {
        _post = _post!.copyWith(isFavorited: response['favorited']);
      });
    } catch (e) {
      // 실패 시 원래 상태로 되돌리기
      setState(() {
        _post = _post!.copyWith(isFavorited: currentFavorited);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('즐겨찾기 실패: $e')));
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await BoardService.createComment(
        postId: widget.postId,
        content: _commentController.text.trim(),
      );

      _commentController.clear();
      _loadComments();

      // 댓글 수 업데이트
      if (_post != null) {
        setState(() {
          _post = _post!.copyWith(commentCount: _post!.commentCount + 1);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 작성 실패: $e')));
    }
  }

  Future<void> _addReply(int parentId) async {
    if (_replyController.text.trim().isEmpty) return;

    try {
      await BoardService.createComment(
        postId: widget.postId,
        content: _replyController.text.trim(),
        parentId: parentId,
      );

      _replyController.clear();
      setState(() {
        _replyingToCommentId = null;
      });
      _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('답글 작성 실패: $e')));
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BoardService.deletePost(widget.postId);
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('게시글 삭제 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('게시글'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: Text('게시글을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_off_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          if (_post!.authorId == 1) // 실제로는 현재 사용자 ID와 비교해야 함
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardEditScreen(post: _post!),
                    ),
                  ).then((_) {
                    _loadPost();
                  });
                } else if (value == 'delete') {
                  _deletePost();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('수정')),
                const PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // 메인 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 사용자 정보
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // 카테고리 태그
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getCategoryName(_post!.category),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 사용자 프로필 정보
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.red[100],
                          child: Text(
                            _post!.author.nickname[0],
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post!.author.nickname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '영화동 인증 13회 · ${_formatDate(_post!.createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 제목
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _post!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 내용
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _post!.content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 이미지들 (있는 경우)
                  if (_post!.images != null && _post!.images!.isNotEmpty) ...[
                    ..._post!.images!.map(
                      (imageUrl) => Container(
                        width: double.infinity,
                        height: 300,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.error,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 추천 태그 및 조회수
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '추천 태그',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.help_outline,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#${_getCategoryName(_post!.category)}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#믹스견',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_post!.viewCount}명이 봤어요',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 반응 버튼들
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('😢', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              const Text('👍', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '${_post!.likeCount}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '저장',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 댓글 섹션
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '댓글 ${_comments.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _changeSortOrder('asc'),
                                  child: Text(
                                    '등록순',
                                    style: TextStyle(
                                      color: _commentSortOrder == 'asc'
                                          ? Colors.black
                                          : Colors.grey[600],
                                      fontSize: 13,
                                      fontWeight: _commentSortOrder == 'asc'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => _changeSortOrder('desc'),
                                  child: Text(
                                    '최신순',
                                    style: TextStyle(
                                      color: _commentSortOrder == 'desc'
                                          ? Colors.black
                                          : Colors.grey[600],
                                      fontSize: 13,
                                      fontWeight: _commentSortOrder == 'desc'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._comments.map(
                          (comment) => _buildCommentWidget(comment),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 댓글 입력창
          if (_isLoggedIn)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 답글 대상 표시 (답글 작성 중일 때만)
                  if (_replyingToCommentId != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '답글 작성 중',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _getReplyTargetComment()?.content ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _replyingToCommentId = null;
                              });
                            },
                            color: Colors.grey[600],
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 댓글 입력 부분
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () {},
                          color: Colors.grey[600],
                        ),
                        IconButton(
                          icon: const Icon(Icons.location_on_outlined),
                          onPressed: () {},
                          color: Colors.grey[600],
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _replyingToCommentId != null
                                  ? _replyController
                                  : _commentController,
                              decoration: InputDecoration(
                                hintText: _replyingToCommentId != null
                                    ? '답글을 입력해주세요.'
                                    : '댓글을 입력해주세요.',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  if (_replyingToCommentId != null) {
                                    _addReply(_replyingToCommentId!);
                                  } else {
                                    _addComment();
                                  }
                                }
                              },
                              textInputAction: TextInputAction.send,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: () {},
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
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

  Widget _buildCommentWidget(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: comment.author.profileImage != null
                    ? NetworkImage(comment.author.profileImage!)
                    : null,
                child: comment.author.profileImage == null
                    ? Text(
                        comment.author.nickname[0],
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 8),

          // 좋아요 및 답글 버튼
          Row(
            children: [
              // 좋아요 버튼
              GestureDetector(
                onTap: () => _toggleCommentLike(comment.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comment.isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 16,
                        color: comment.isLiked ? Colors.blue : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '좋아요 ${comment.likeCount}',
                        style: TextStyle(
                          color: comment.isLiked
                              ? Colors.blue
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 답글 버튼
              GestureDetector(
                onTap: () => _onReply(comment.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '답글쓰기',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 답글 표시
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...comment.replies.map(
              (reply) => Container(
                margin: const EdgeInsets.only(left: 20, top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: reply.author.profileImage != null
                              ? NetworkImage(reply.author.profileImage!)
                              : null,
                          child: reply.author.profileImage == null
                              ? Text(
                                  reply.author.nickname[0],
                                  style: const TextStyle(fontSize: 10),
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reply.author.nickname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDate(reply.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(reply.content, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onReply(int commentId) {
    setState(() {
      _replyingToCommentId = commentId;
    });
  }

  Comment? _getReplyTargetComment() {
    if (_replyingToCommentId == null) return null;
    try {
      return _comments.firstWhere(
        (comment) => comment.id == _replyingToCommentId,
      );
    } catch (e) {
      return null;
    }
  }

  void _changeSortOrder(String sortOrder) {
    if (_commentSortOrder != sortOrder) {
      setState(() {
        _commentSortOrder = sortOrder;
      });
      _loadComments(); // 정렬 변경 후 댓글 다시 로드
    }
  }

  Future<void> _toggleCommentLike(int commentId) async {
    // 댓글 찾기
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];

    // 즉시 UI 업데이트 (낙관적 업데이트)
    final currentLiked = comment.isLiked;
    final currentLikeCount = comment.likeCount;

    setState(() {
      _comments[commentIndex] = comment.copyWith(
        isLiked: !currentLiked,
        likeCount: currentLiked ? currentLikeCount - 1 : currentLikeCount + 1,
      );
    });

    try {
      final response = await BoardService.toggleCommentLike(commentId);
      // 서버 응답으로 최종 상태 업데이트
      setState(() {
        _comments[commentIndex] = comment.copyWith(
          isLiked: response['liked'],
          likeCount:
              response['like_count'] ??
              (currentLiked ? currentLikeCount - 1 : currentLikeCount + 1),
        );
      });
    } catch (e) {
      // 실패 시 원래 상태로 되돌리기
      setState(() {
        _comments[commentIndex] = comment.copyWith(
          isLiked: currentLiked,
          likeCount: currentLikeCount,
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 좋아요 실패: $e')));
    }
  }
}
