import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KakaoAuthService {
  static const String baseUrl = 'http://localhost:8000';

  // 카카오 SDK 초기화
  static void initializeKakaoSDK() {
    KakaoSdk.init(
      nativeAppKey: '646fac0f5c73396bcf59e5850407c4b3', // 실제 네이티브 앱 키
    );
  }

  // 카카오 로그인 처리
  static Future<Map<String, dynamic>?> loginWithKakao(
    BuildContext context,
  ) async {
    try {
      OAuthToken token;

      // 웹뷰 로그인으로 강제 시도 (URL 스킴 설정 없이도 작동)
      print('웹뷰 로그인으로 시도...');
      token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오 계정으로 로그인 성공');

      // 사용자 정보 가져오기
      User user = await UserApi.instance.me();
      print('사용자 정보: ${user.kakaoAccount?.profile?.nickname}');

      // 백엔드 서버에 토큰 전송
      final result = await _sendTokenToBackend(token, user);

      return result;
    } on KakaoClientException catch (e) {
      // 카카오 클라이언트 오류
      print('카카오 클라이언트 오류: ${e.msg}');
      _showErrorDialog(context, '카카오 로그인 오류: ${e.msg}');
      return null;
    } on KakaoAuthException catch (e) {
      // 카카오 인증 오류
      print('카카오 인증 오류: ${e.error}');
      _showErrorDialog(context, '인증 오류: ${e.error}');
      return null;
    } catch (e) {
      // 기타 오류
      print('기타 오류: $e');
      _showErrorDialog(context, '로그인 오류: $e');
      return null;
    }
  }

  // 카카오톡 앱 설치 여부 확인
  static Future<bool> checkKakaoTalkInstalled() async {
    try {
      return await isKakaoTalkInstalled();
    } catch (e) {
      return false;
    }
  }

  // 백엔드 서버에 토큰 전송
  static Future<Map<String, dynamic>> _sendTokenToBackend(
    OAuthToken token,
    User user,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/kakao/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'access_token': token.accessToken,
          'refresh_token': token.refreshToken,
          'user_info': {
            'id': user.id,
            'nickname': user.kakaoAccount?.profile?.nickname,
            'email': user.kakaoAccount?.email,
            'profile_image': user.kakaoAccount?.profile?.profileImageUrl,
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        // JWT 토큰을 SharedPreferences에 저장
        if (result['access_token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', result['access_token']);
          print('JWT 토큰 저장됨: ${result['access_token']}');
          print('토큰 길이: ${result['access_token'].length}');
        } else {
          print('백엔드 응답에 access_token이 없음');
          print('전체 응답: $result');
        }

        return result;
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('백엔드 연결 오류: $e');
    }
  }

  // 카카오 로그인 처리 (확인 다이얼로그 먼저 표시)
  static Future<Map<String, dynamic>?> showKakaoLoginDialog(
    BuildContext context,
  ) async {
    try {
      // 먼저 확인 다이얼로그 표시
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그인'),
            content: const Text('카카오로 로그인하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('로그인'),
              ),
            ],
          );
        },
      );

      // 사용자가 취소했으면 null 반환
      if (shouldLogin != true) {
        return null;
      }

      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              width: 200,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFFEE500),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '카카오 로그인 중...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // 카카오 로그인 실행
      final result = await loginWithKakao(context);

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      if (result != null) {
        // 로그인 성공 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공: ${result['user_info']['nickname']}'),
            backgroundColor: Colors.green,
          ),
        );
        return result;
      } else {
        // 로그인 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인에 실패했습니다.'), backgroundColor: Colors.red),
        );
        return null;
      }
    } catch (e) {
      // 로딩 다이얼로그가 열려있으면 닫기
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorDialog(context, '로그인 오류: $e');
      return null;
    }
  }

  // 오류 다이얼로그 표시
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 로그아웃
  static Future<void> logout() async {
    try {
      await UserApi.instance.logout();

      // SharedPreferences에서 토큰 제거
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      print('JWT 토큰 제거됨');
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }

  // 현재 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    try {
      await UserApi.instance.me();
      return true;
    } catch (e) {
      return false;
    }
  }
}
