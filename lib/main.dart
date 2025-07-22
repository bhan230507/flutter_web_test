import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'profile_user.dart';
import 'profile_pet.dart';
import 'nav_saju.dart';
import 'nav_compatibility.dart';
import 'nav_tarot.dart';
import 'nav_mbti.dart';
import 'nav_settings.dart';
import 'nav_board.dart';
import 'services/kakao_auth_service.dart';
import 'globals.dart';
import 'screens/signup_screen.dart';

void main() {
  // 카카오 SDK 초기화
  KakaoAuthService.initializeKakaoSDK();
  runApp(const SajuApp());
}

class SajuApp extends StatelessWidget {
  const SajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Saju',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: null,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainHomePage(),
    );
  }
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  late TabController _sajuTabController;
  late TabController _compatibilityTabController;
  late TabController _tarotTabController;
  late TabController _mbtiTabController;
  int _currentTabIndex = 0;

  // 선택된 사용자와 애견 정보
  Map<String, dynamic>? _selectedUser;
  Map<String, dynamic>? _selectedPet;

  // 로그인된 사용자 정보 (전역 변수로 대체)
  // Map<String, dynamic>? _loggedInUser;

  final List<Map<String, dynamic>> navItems = [
    {'label': '사주', 'icon': Icons.person_outline},
    {'label': '궁합', 'icon': Icons.favorite_border},
    {'label': '타로', 'icon': Icons.style},
    {'label': 'MBTI', 'icon': Icons.psychology},
    {'label': '게시판', 'icon': Icons.forum},
    {'label': '설정', 'icon': Icons.settings},
  ];

  final List<String> noticeImages = [
    'assets/images/event1.jpg',
    'assets/images/event2.jpg',
    'assets/images/event3.jpg',
  ];

  final List<Map<String, String>> noticeTexts = [
    {'badge': '이벤트', 'title': '새해 맞이 특별 이벤트', 'subtitle': '2025년 운세 무료 상담'},
    {'badge': '신규', 'title': '반려견 운세 서비스', 'subtitle': '우리집 강아지 사주보기'},
    {'badge': '할인', 'title': '타로 상담 50% 할인', 'subtitle': '한정 기간 특가 이벤트'},
  ];
  int _currentNotice = 0;
  late final PageController _pageController;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _sajuTabController = TabController(
      length: 2, // 내사주, 개사주
      vsync: this,
      initialIndex: 1,
    );
    _compatibilityTabController = TabController(
      length: 2, // 인간궁합, 반려동물궁합
      vsync: this,
      initialIndex: 0,
    );
    _tarotTabController = TabController(
      length: 1, // 타로
      vsync: this,
      initialIndex: 0,
    );
    _mbtiTabController = TabController(
      length: 2, // 내BTI, 개BTI
      vsync: this,
      initialIndex: 1, // 개BTI 탭이 먼저 활성화
    );
    _pageController = PageController();
    _startAutoScroll();

    // 토큰 유효성 확인
    _checkTokenValidity();

    // 로그인 상태 주기적 확인 시작
    _startLoginStatusCheck();
  }

  Future<void> _checkTokenValidity() async {
    await Globals.checkTokenValidity();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  // 주기적으로 로그인 상태 확인
  void _startLoginStatusCheck() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        Globals.checkTokenValidity();
        setState(() {}); // UI 새로고침
      } else {
        timer.cancel();
      }
    });
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentNotice + 1) % noticeImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // 로그아웃 처리 (전역)
  void _handleLogout() async {
    try {
      // 로그아웃 확인 다이얼로그
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('로그아웃'),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        // 전역 로그아웃 처리
        await Globals.logout();

        // UI 상태 초기화
        setState(() {
          _selectedUser = null;
          _selectedPet = null;
        });

        // 성공 메시지
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그아웃되었습니다.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 카카오 로그인 처리
  void _handleKakaoLogin() async {
    try {
      final result = await KakaoAuthService.showKakaoLoginDialog(context);
      if (result != null) {
        // 새 사용자인지 확인
        final isNewUser = result['user_info']['is_new_user'] ?? false;

        if (isNewUser) {
          // 새 사용자: 회원가입 화면으로 이동
          final signupResult = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SignupScreen(
                kakaoUserInfo: result['user_info'],
                onSignupComplete: (updatedUserInfo) {
                  // 회원가입 완료 후 로그인 처리
                  final updatedResult = {
                    ...result,
                    'user_info': updatedUserInfo,
                  };
                  Globals.setLoggedInUser(updatedResult);
                  setState(() {});
                },
              ),
            ),
          );
        } else {
          // 기존 사용자: 바로 로그인
          Globals.setLoggedInUser(result);
          setState(() {});

          // 게시판 탭이 활성화되어 있다면 강제로 새로고침
          if (_currentTabIndex == 4) {
            setState(() {});
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 성공: ${result['user_info']['nickname']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _sajuTabController.dispose();
    _compatibilityTabController.dispose();
    _tarotTabController.dispose();
    _mbtiTabController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(child: _buildCurrentTabContent()),
      bottomNavigationBar: Container(
        height: 60,
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFE91E63),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 20,
          items: navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item['icon']),
                  label: item['label'],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTabIndex) {
      case 0: // 사주
        return NavSaju.buildSajuTab(
          context: context,
          sajuTabController: _sajuTabController,
          selectedUser: _selectedUser,
          selectedPet: _selectedPet,
          onUserSelected: (user) => setState(() => _selectedUser = user),
          onPetSelected: (pet) => setState(() => _selectedPet = pet),
          noticeImages: noticeImages,
          noticeTexts: noticeTexts,
          pageController: _pageController,
          currentNotice: _currentNotice,
          onPageChanged: (idx) => setState(() => _currentNotice = idx),
          onScrollStart: () => _carouselTimer?.cancel(),
          onScrollEnd: _startAutoScroll,
          onKakaoLogin: _handleKakaoLogin,
          onLogout: _handleLogout,
        );
      case 1: // 궁합
        return NavCompatibility.buildCompatibilityTab(
          context: context,
          compatibilityTabController: _compatibilityTabController,
          selectedUser: _selectedUser,
          selectedPet: _selectedPet,
          onUserSelected: (user) => setState(() => _selectedUser = user),
          onPetSelected: (pet) => setState(() => _selectedPet = pet),
          noticeImages: noticeImages,
          noticeTexts: noticeTexts,
          pageController: _pageController,
          currentNotice: _currentNotice,
          onPageChanged: (idx) => setState(() => _currentNotice = idx),
          onScrollStart: () => _carouselTimer?.cancel(),
          onScrollEnd: _startAutoScroll,
          onKakaoLogin: _handleKakaoLogin,
          onLogout: _handleLogout,
        );
      case 2: // 타로
        return NavTarot.buildTarotTab(
          context: context,
          tarotTabController: _tarotTabController,
          selectedUser: _selectedUser,
          selectedPet: _selectedPet,
          onUserSelected: (user) => setState(() => _selectedUser = user),
          onPetSelected: (pet) => setState(() => _selectedPet = pet),
          noticeImages: noticeImages,
          noticeTexts: noticeTexts,
          pageController: _pageController,
          currentNotice: _currentNotice,
          onPageChanged: (idx) => setState(() => _currentNotice = idx),
          onScrollStart: () => _carouselTimer?.cancel(),
          onScrollEnd: _startAutoScroll,
          onKakaoLogin: _handleKakaoLogin,
          onLogout: _handleLogout,
        );
      case 3: // MBTI
        return NavMbti.buildMbtiTab(
          context: context,
          mbtiTabController: _mbtiTabController,
          selectedUser: _selectedUser,
          selectedPet: _selectedPet,
          onUserSelected: (user) => setState(() => _selectedUser = user),
          onPetSelected: (pet) => setState(() => _selectedPet = pet),
          noticeImages: noticeImages,
          noticeTexts: noticeTexts,
          pageController: _pageController,
          currentNotice: _currentNotice,
          onPageChanged: (idx) => setState(() => _currentNotice = idx),
          onScrollStart: () => _carouselTimer?.cancel(),
          onScrollEnd: _startAutoScroll,
          onKakaoLogin: _handleKakaoLogin,
          onLogout: _handleLogout,
        );
      case 4: // 게시판
        return NavBoard.buildBoardTab(
          context: context,
          selectedUser: _selectedUser,
          selectedPet: _selectedPet,
          onUserSelected: (user) => setState(() => _selectedUser = user),
          onPetSelected: (pet) => setState(() => _selectedPet = pet),
          noticeImages: noticeImages,
          noticeTexts: noticeTexts,
          pageController: _pageController,
          currentNotice: _currentNotice,
          onPageChanged: (idx) => setState(() => _currentNotice = idx),
          onScrollStart: () => _carouselTimer?.cancel(),
          onScrollEnd: _startAutoScroll,
          onKakaoLogin: _handleKakaoLogin,
          onLogout: _handleLogout,
        );
      case 5: // 설정
        return NavSettings.buildSettingsTab();
      default:
        return NavSaju.buildSajuTab(
          context: context,
          sajuTabController: _sajuTabController,
          selectedUser: _selectedUser,
          selectedPet: _selectedPet,
          onUserSelected: (user) => setState(() => _selectedUser = user),
          onPetSelected: (pet) => setState(() => _selectedPet = pet),
          noticeImages: noticeImages,
          noticeTexts: noticeTexts,
          pageController: _pageController,
          currentNotice: _currentNotice,
          onPageChanged: (idx) => setState(() => _currentNotice = idx),
          onScrollStart: () => _carouselTimer?.cancel(),
          onScrollEnd: _startAutoScroll,
          onKakaoLogin: _handleKakaoLogin,
          onLogout: _handleLogout,
        );
    }
  }
}
