import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  final Map<String, dynamic> kakaoUserInfo;
  final Function(Map<String, dynamic>) onSignupComplete;

  const SignupScreen({
    Key? key,
    required this.kakaoUserInfo,
    required this.onSignupComplete,
  }) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isChecking = false;
  bool _bothFieldsFilled = false;
  bool _isAvailable = false;
  String _checkMessage = '';

  @override
  void initState() {
    super.initState();
    // 카카오에서 받은 정보로 초기값 설정
    _nicknameController.text = widget.kakaoUserInfo['nickname'] ?? '';
    _emailController.text = widget.kakaoUserInfo['email'] ?? '';

    // 텍스트 변경 리스너 추가
    _nicknameController.addListener(_checkBothFields);
    _emailController.addListener(_checkBothFields);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 두 필드가 모두 입력되었는지 확인
  void _checkBothFields() {
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _bothFieldsFilled = nickname.isNotEmpty && email.isNotEmpty;
      if (!_bothFieldsFilled) {
        _isAvailable = false;
        _checkMessage = '';
      }
    });
  }

  // 앱 닉네임과 이메일 중복 체크 (한 번에)
  Future<void> _checkAppInfo() async {
    if (!_bothFieldsFilled) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/check-app-info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'app_nickname': _nicknameController.text.trim(),
          'app_email': _emailController.text.trim(),
        }),
      );

      setState(() {
        _isAvailable = response.statusCode == 200;
        _checkMessage = response.statusCode == 200
            ? '사용 가능한 닉네임과 이메일입니다'
            : '이미 사용 중인 닉네임 또는 이메일입니다';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _checkMessage = '중복 체크 중 오류가 발생했습니다';
        _isChecking = false;
      });
    }
  }

  // 회원가입 완료
  Future<void> _completeSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_bothFieldsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임과 이메일을 모두 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('중복 체크를 완료해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 백엔드에 회원가입 완료 요청
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/complete-signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'kakao_id': widget.kakaoUserInfo['id'],
          'app_nickname': _nicknameController.text.trim(),
          'app_email': _emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final updatedUserInfo = result['user_info'];

        widget.onSignupComplete(updatedUserInfo);

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('회원가입 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3C1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Color(0xFF3C1E1E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '추가 정보를 입력해주세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C1E1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '카카오 계정으로 간편하게 가입하세요',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 앱 닉네임 입력
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '앱 닉네임',
                  hintText: '사용할 닉네임을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  if (value.length < 2) {
                    return '닉네임은 2자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 앱 이메일 입력
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '앱 이메일',
                  hintText: '이메일을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return '올바른 이메일 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 중복 체크 버튼
              if (_bothFieldsFilled) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkAppInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            '중복 체크',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_checkMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isAvailable ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAvailable ? Icons.check_circle : Icons.error,
                          color: _isAvailable ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _checkMessage,
                            style: TextStyle(
                              color: _isAvailable ? Colors.green : Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isAvailable)
                      ? null
                      : _completeSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '회원가입 완료',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
