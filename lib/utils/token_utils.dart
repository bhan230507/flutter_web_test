import 'dart:convert';

class TokenUtils {
  /// JWT 토큰이 유효한지 확인
  static bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }

    // 테스트 토큰 거부
    if (token == "test_token_123" || token.startsWith("test_")) {
      return false;
    }

    // JWT 토큰 형식 검사
    final parts = token.split('.');
    if (parts.length != 3) {
      return false;
    }

    try {
      // 페이로드 디코딩
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      // 만료 시간 확인
      final exp = payloadMap['exp'];
      if (exp == null) {
        return false;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      return now.isBefore(expirationTime);
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  /// 토큰에서 사용자 정보 추출
  static Map<String, dynamic>? getTokenPayload(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return json.decode(resp);
    } catch (e) {
      print('Token payload extraction error: $e');
      return null;
    }
  }

  /// 토큰에서 사용자 ID 추출
  static String? getUserId(String? token) {
    final payload = getTokenPayload(token);
    return payload?['sub'];
  }

  /// 토큰에서 사용자 닉네임 추출
  static String? getUserNickname(String? token) {
    final payload = getTokenPayload(token);
    return payload?['nickname'];
  }
}
