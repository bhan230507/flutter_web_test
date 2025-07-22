import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils/token_utils.dart';

// 전역 상태 관리
class Globals {
  static Map<String, dynamic>? loggedInUser;

  // 로그인 상태 변경 콜백 리스트
  static final List<Function(bool)> _loginStateCallbacks = [];

  // 로그인 상태 변경 콜백 등록
  static void addLoginStateCallback(Function(bool) callback) {
    _loginStateCallbacks.add(callback);
  }

  // 로그인 상태 변경 콜백 제거
  static void removeLoginStateCallback(Function(bool) callback) {
    _loginStateCallbacks.remove(callback);
  }

  // 로그인 상태 변경 알림
  static void _notifyLoginStateChange(bool isLoggedIn) {
    for (final callback in _loginStateCallbacks) {
      try {
        callback(isLoggedIn);
      } catch (e) {
        print('Login state callback error: $e');
      }
    }
  }

  static void setLoggedInUser(Map<String, dynamic>? user) {
    final wasLoggedIn = loggedInUser != null;
    final isNowLoggedIn = user != null;

    loggedInUser = user;

    // 로그인 상태가 변경되었을 때만 알림
    if (wasLoggedIn != isNowLoggedIn) {
      _notifyLoginStateChange(isNowLoggedIn);
    }
  }

  static Map<String, dynamic>? getLoggedInUser() {
    return loggedInUser;
  }

  static bool isLoggedIn() {
    // 토큰이 있으면 로그인된 것으로 간주
    return loggedInUser != null;
  }

  static Future<bool> isLoggedInAsync() async {
    // SharedPreferences에서 토큰 확인
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      return false;
    }

    // 토큰 유효성 검사
    final isTokenValid = TokenUtils.isTokenValid(token);

    // 토큰이 유효하면 사용자 정보 복원
    if (isTokenValid && loggedInUser == null) {
      await checkTokenValidity();
    }

    return loggedInUser != null;
  }

  static Future<void> checkTokenValidity() async {
    // 토큰 유효성 확인
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final isTokenValid = TokenUtils.isTokenValid(token);

    // 토큰 체크 로그를 줄임 (디버깅 시에만 주석 해제)
    // print('Token validity check - Token: $token, IsValid: $isTokenValid');

    if (isTokenValid && token != null) {
      // 토큰이 유효하면 사용자 정보 복원
      if (loggedInUser == null) {
        // 토큰에서 사용자 정보 추출
        final payload = TokenUtils.getTokenPayload(token);
        if (payload != null) {
          // 기본 사용자 정보 설정
          loggedInUser = {
            'access_token': token,
            'user_info': {
              'id': payload['sub'],
              'nickname': payload['nickname'],
              'email': payload['email'],
              'profile_image': null,
            },
          };

          // 백엔드에서 상세 사용자 정보 조회 (프로필 이미지 포함)
          try {
            final response = await http.get(
              Uri.parse('http://localhost:8000/auth/me'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              final userData = json.decode(response.body);
              loggedInUser = {
                'access_token': token,
                'user_info': {
                  'id': userData['user_id'],
                  'nickname': userData['nickname'], // 백엔드에서 가져온 닉네임 사용
                  'email': userData['email'],
                  'profile_image':
                      userData['profile_image'], // 백엔드에서 프로필 이미지 가져오기
                },
              };
            }
          } catch (e) {
            print('사용자 정보 조회 실패: $e');
            // 실패해도 기본 정보는 유지
          }
        }
      }
    } else {
      // 토큰이 유효하지 않으면 로그아웃 처리
      if (loggedInUser != null || token != null) {
        print('Token is invalid, logging out...');
        await logout();
      }
    }
  }

  static Future<void> logout() async {
    // SharedPreferences에서 토큰 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    // 전역 상태에서 사용자 정보 삭제
    final wasLoggedIn = loggedInUser != null;
    loggedInUser = null;

    // 로그인 상태가 변경되었을 때만 알림
    if (wasLoggedIn) {
      _notifyLoginStateChange(false);
    }
  }
}
