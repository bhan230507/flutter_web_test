import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

class BoardService {
  static const String baseUrl = 'http://localhost:8000'; // 실제 서버 URL로 변경 필요

  // 게시글 관련
  static Future<Map<String, dynamic>> getPosts({
    int page = 1,
    int size = 10,
    String? category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };

    if (category != null) {
      queryParams['category'] = category;
    }

    final uri = Uri.parse(
      '$baseUrl/board/posts',
    ).replace(queryParameters: queryParams);

    final headers = <String, String>{'Content-Type': 'application/json'};

    // 토큰이 있으면 Authorization 헤더 추가
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print('API Response: $data'); // 디버깅용
        return data;
      } catch (e) {
        print('JSON decode error: $e');
        throw Exception('Failed to parse response: $e');
      }
    } else {
      print('Error response: ${response.statusCode} - ${response.body}');
      print('Request headers: $headers'); // 디버깅용
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getPost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('$baseUrl/board/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    required String category,
    List<String>? images,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    print('Create post - Token: $token'); // 디버깅용

    final headers = <String, String>{'Content-Type': 'application/json'};

    // 토큰이 있으면 Authorization 헤더 추가
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('$baseUrl/board/posts'),
      headers: headers,
      body: json.encode({
        'title': title,
        'content': content,
        'category': category,
        'images': images,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Create post error: ${response.statusCode} - ${response.body}');
      print('Request headers: $headers');
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> updatePost({
    required int postId,
    String? title,
    String? content,
    String? category,
    List<String>? images,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.put(
      Uri.parse('$baseUrl/board/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (category != null) 'category': category,
        if (images != null) 'images': images,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update post');
    }
  }

  static Future<void> deletePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/board/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }

  static Future<Map<String, dynamic>> toggleLike(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/board/posts/$postId/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Toggle like error: ${response.statusCode} - ${response.body}');
      print('Request headers: Authorization: Bearer $token');
      throw Exception('Failed to toggle like: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> toggleFavorite(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/board/posts/$postId/favorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Toggle favorite error: ${response.statusCode} - ${response.body}');
      print('Request headers: Authorization: Bearer $token');
      throw Exception('Failed to toggle favorite: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getFavoritePosts({
    int page = 1,
    int size = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/board/favorites?page=$page&size=$size'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load favorite posts');
    }
  }

  // 댓글 관련
  static Future<Map<String, dynamic>> getComments({
    required int postId,
    int page = 1,
    int size = 20,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('$baseUrl/board/posts/$postId/comments?page=$page&size=$size'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  static Future<Map<String, dynamic>> createComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/board/posts/$postId/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create comment');
    }
  }

  static Future<Map<String, dynamic>> updateComment({
    required int commentId,
    required String content,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/board/comments/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update comment');
    }
  }

  static Future<void> deleteComment(int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/board/comments/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }

  static Future<Map<String, dynamic>> toggleCommentLike(int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/board/comments/$commentId/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(
        'Toggle comment like error: ${response.statusCode} - ${response.body}',
      );
      print('Request headers: Authorization: Bearer $token');
      throw Exception('Failed to toggle comment like: ${response.statusCode}');
    }
  }

  // 이미지 압축
  static Future<File> compressImage(
    File imageFile, {
    int maxWidth = 720,
    int maxHeight = 720,
    int quality = 70,
  }) async {
    try {
      print('이미지 압축 시작: ${imageFile.path}');

      // 원본 이미지 읽기
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        print('이미지 디코딩 실패');
        return imageFile;
      }

      print('원본 이미지 크기: ${image.width} x ${image.height}');

      // 리사이즈가 필요한지 확인
      if (image.width <= maxWidth && image.height <= maxHeight) {
        print('리사이즈 불필요, 품질만 조정');
        // 품질만 조정
        final compressedBytes = img.encodeJpg(image, quality: quality);
        final compressedFile = File('${imageFile.path}_compressed.jpg');
        await compressedFile.writeAsBytes(compressedBytes);
        return compressedFile;
      }

      // 리사이즈
      final resizedImage = img.copyResize(
        image,
        width: image.width > image.height ? maxWidth : null,
        height: image.height > image.width ? maxHeight : null,
        interpolation: img.Interpolation.linear,
      );

      print('압축 후 이미지 크기: ${resizedImage.width} x ${resizedImage.height}');

      // JPEG로 압축
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      // 압축된 파일 저장
      final compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      final originalSize = await imageFile.length();
      final compressedSize = await compressedFile.length();
      final compressionRatio =
          ((originalSize - compressedSize) / originalSize * 100)
              .toStringAsFixed(1);

      print(
        '압축 완료: ${originalSize} bytes → ${compressedSize} bytes (${compressionRatio}% 감소)',
      );

      return compressedFile;
    } catch (e) {
      print('이미지 압축 실패: $e');
      return imageFile; // 압축 실패 시 원본 반환
    }
  }

  // 이미지 업로드
  static Future<String> uploadImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    try {
      print('이미지 업로드 준비: ${imageFile.path}');

      // 이미지 압축
      File fileToUpload = imageFile;
      final originalSize = await imageFile.length();

      if (originalSize > 100 * 1024) {
        // 100KB 이상이면 압축 (기준을 낮춤)
        print('이미지 압축 시작 (100KB 이상)');
        fileToUpload = await compressImage(
          imageFile,
          maxWidth: 600, // 크기를 더 줄임 (720 → 600)
          maxHeight: 600, // 크기를 더 줄임 (720 → 600)
          quality: 60, // 품질을 더 낮춤 (70 → 60)
        );
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/board/upload-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // 파일 크기 확인 (10MB 제한)
      final fileSize = await fileToUpload.length();
      print(
        '업로드 파일 크기: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
      );

      if (fileSize > 150 * 1024) {
        throw Exception('파일 크기는 150KB 이하여야 합니다.');
      }

      // 파일 존재 확인
      if (!await imageFile.exists()) {
        throw Exception('파일이 존재하지 않습니다: ${imageFile.path}');
      }

      // 파일 확장자 확인
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      print('파일명: $fileName, 확장자: $fileExtension');

      // 파일 확장자에 따른 MIME 타입 설정
      String mimeType = 'image/jpeg'; // 기본값
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'heic':
        case 'heif':
          mimeType = 'image/heic';
          break;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          fileToUpload.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      print('이미지 업로드 시작: ${imageFile.path}');
      print('요청 헤더: ${request.headers}');

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      print('업로드 응답: ${response.statusCode} - $responseData');

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        final imageUrl = data['image_url'];
        print('업로드 성공: $imageUrl');
        return imageUrl;
      } else {
        print('업로드 실패: ${response.statusCode} - $responseData');
        throw Exception('이미지 업로드 실패: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      print('이미지 업로드 에러: $e');
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  // 여러 이미지 병렬 업로드
  static Future<List<String>> uploadImages(List<File> imageFiles) async {
    print('병렬 이미지 업로드 시작: ${imageFiles.length}개');

    try {
      // 모든 이미지를 병렬로 업로드
      final futures = imageFiles.map((file) => uploadImage(file));
      final results = await Future.wait(futures);

      print('병렬 업로드 완료: ${results.length}개 성공');
      return results;
    } catch (e) {
      print('병렬 업로드 실패: $e');
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  // 카테고리 목록
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final headers = <String, String>{'Content-Type': 'application/json'};

    // 토큰이 있으면 Authorization 헤더 추가
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/board/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['categories']);
    } else {
      print('Error response: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }
}
