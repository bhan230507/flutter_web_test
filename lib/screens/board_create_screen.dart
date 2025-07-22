import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/board_service.dart';
import '../models/board_models.dart';

class BoardCreateScreen extends StatefulWidget {
  const BoardCreateScreen({Key? key}) : super(key: key);

  @override
  _BoardCreateScreenState createState() => _BoardCreateScreenState();
}

class _BoardCreateScreenState extends State<BoardCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _selectedCategory;
  List<Category> _categories = [];
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지는 최대 10개까지 선택할 수 있습니다.')),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920, // 최대 너비 제한
        maxHeight: 1920, // 최대 높이 제한
        imageQuality: 85, // 이미지 품질 (85%)
      );

      if (images.isNotEmpty) {
        // 선택 가능한 이미지 개수 계산
        final remainingSlots = 10 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${remainingSlots}개의 이미지만 추가되었습니다. (최대 10개)'),
            ),
          );
        }

        setState(() {
          _selectedImages.addAll(imagesToAdd.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 선택 실패: $e')));
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // 병렬 업로드로 변경
      final imageUrls = await BoardService.uploadImages(_selectedImages);
      _uploadedImageUrls.addAll(imageUrls);

      print('병렬 업로드 완료: ${imageUrls.length}개 이미지');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _createPost() async {
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
      // 이미지 업로드
      if (_selectedImages.isNotEmpty) {
        await _uploadImages();
      }

      // 게시글 생성
      await BoardService.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory!,
        images: _uploadedImageUrls.isNotEmpty ? _uploadedImageUrls : null,
      );

      // 성공 다이얼로그 표시
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('작성 완료'),
              ],
            ),
            content: const Text('게시글이 성공적으로 작성되었습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.pop(context, true); // 작성 화면 닫기
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('게시글 생성 실패: $e')));
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
        title: const Text('게시글 작성'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _createPost,
              child: const Text(
                '작성',
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

                    // 이미지 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '이미지 (최대 10개)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_selectedImages.length}/10',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 이미지 선택 버튼
                    ElevatedButton.icon(
                      onPressed: _selectedImages.length >= 10
                          ? null
                          : _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('이미지 선택'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 선택된 이미지 미리보기
                    if (_selectedImages.isNotEmpty) ...[
                      const Text(
                        '선택된 이미지',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 업로드 진행 상태
                    if (_isUploading) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text(
                        '이미지 업로드 중...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 작성 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createPost,
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
                                '게시글 작성',
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
