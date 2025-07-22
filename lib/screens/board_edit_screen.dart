import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../services/board_service.dart';
import '../models/board_models.dart';

class BoardEditScreen extends StatefulWidget {
  final Post post;

  const BoardEditScreen({Key? key, required this.post}) : super(key: key);

  @override
  _BoardEditScreenState createState() => _BoardEditScreenState();
}

class _BoardEditScreenState extends State<BoardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  String? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _selectedCategory = widget.post.category;
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await BoardService.getCategories();
      setState(() {
        _categories = categoriesData
            .map((json) => Category.fromJson(json))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('카테고리 로드 실패: $e')));
    }
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await BoardService.updatePost(
        postId: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory!,
        images: widget.post.images,
      );

      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('게시글 수정 실패: $e')));
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
        title: const Text('게시글 수정'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updatePost,
              child: const Text(
                '수정',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 선택
                    const Text(
                      '카테고리',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '카테고리를 선택하세요',
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return '카테고리를 선택해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 제목 입력
                    const Text(
                      '제목',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '제목을 입력하세요',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '제목을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 내용 입력
                    const Text(
                      '내용',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '내용을 입력하세요',
                      ),
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '내용을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 기존 이미지 표시
                    if (widget.post.images != null &&
                        widget.post.images!.isNotEmpty) ...[
                      const Text(
                        '기존 이미지',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.post.images!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: widget.post.images![index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      ),
                                  httpHeaders: {
                                    'User-Agent':
                                        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1',
                                    'Accept':
                                        'image/webp,image/apng,image/*,*/*;q=0.8',
                                    'Accept-Language':
                                        'ko-KR,ko;q=0.9,en;q=0.8',
                                    'Cache-Control': 'no-cache',
                                  },
                                  maxWidthDiskCache: 200,
                                  maxHeightDiskCache: 200,
                                  memCacheWidth: 200,
                                  memCacheHeight: 200,
                                  fadeInDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  fadeOutDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 수정 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                '게시글 수정',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
