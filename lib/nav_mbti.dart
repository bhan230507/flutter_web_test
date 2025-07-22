import 'package:flutter/material.dart';
import 'nav_common.dart';

class NavMbti {
  static Widget buildMbtiTab({
    required BuildContext context,
    required TabController mbtiTabController,
    required Map<String, dynamic>? selectedUser,
    required Map<String, dynamic>? selectedPet,
    required Function(Map<String, dynamic>) onUserSelected,
    required Function(Map<String, dynamic>) onPetSelected,
    required List<String> noticeImages,
    required List<Map<String, String>> noticeTexts,
    required PageController pageController,
    required int currentNotice,
    required Function(int) onPageChanged,
    required VoidCallback onScrollStart,
    required VoidCallback onScrollEnd,
    required VoidCallback onKakaoLogin,
    required VoidCallback onLogout,
  }) {
    final List<Map<String, dynamic>> humanMbtiMenus = [
      {
        'icon': Icons.psychology,
        'title': 'MBTI 검사',
        'subtitle': '16가지 성격유형 분석',
        'enabled': true,
      },
      {
        'icon': Icons.favorite,
        'title': 'MBTI 궁합',
        'subtitle': '성격유형별 궁합',
        'enabled': false,
      },
      {
        'icon': Icons.work,
        'title': 'MBTI 직업',
        'subtitle': '성격에 맞는 직업',
        'enabled': false,
      },
      {
        'icon': Icons.school,
        'title': 'MBTI 학습',
        'subtitle': '학습 스타일 분석',
        'enabled': false,
      },
      {
        'icon': Icons.people,
        'title': 'MBTI 인간관계',
        'subtitle': '대인관계 패턴',
        'enabled': false,
      },
      {
        'icon': Icons.emoji_emotions,
        'title': 'MBTI 연애',
        'subtitle': '연애 성향 분석',
        'enabled': false,
      },
    ];

    final List<Map<String, dynamic>> petMbtiMenus = [
      {
        'icon': Icons.pets,
        'title': '개BTI 검사',
        'subtitle': '강아지 성격유형 분석',
        'enabled': true,
      },
      {
        'icon': Icons.pets,
        'title': '냥BTI 검사',
        'subtitle': '고양이 성격유형 분석',
        'enabled': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top right: profile icons
        NavCommon.buildProfileIcons(
          context: context,
          selectedUser: selectedUser,
          selectedPet: selectedPet,
          onUserSelected: onUserSelected,
          onPetSelected: onPetSelected,
          onKakaoLogin: onKakaoLogin,
          onLogout: onLogout,
        ),

        // TabBar for MBTI
        Theme(
          data: Theme.of(context).copyWith(
            tabBarTheme: const TabBarThemeData(
              tabAlignment: TabAlignment.start,
            ),
          ),
          child: SizedBox(
            height: 44,
            child: TabBar(
              controller: mbtiTabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFE91E63),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: ['내BTI', '개BTI'].map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
        // TabBarView for MBTI
        Expanded(
          child: TabBarView(
            controller: mbtiTabController,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    NavCommon.buildNoticeCarousel(
                      context: context,
                      noticeImages: noticeImages,
                      noticeTexts: noticeTexts,
                      pageController: pageController,
                      currentNotice: currentNotice,
                      onPageChanged: onPageChanged,
                      onScrollStart: onScrollStart,
                      onScrollEnd: onScrollEnd,
                    ),
                    NavCommon.buildMenuGrid(humanMbtiMenus),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    NavCommon.buildNoticeCarousel(
                      context: context,
                      noticeImages: noticeImages,
                      noticeTexts: noticeTexts,
                      pageController: pageController,
                      currentNotice: currentNotice,
                      onPageChanged: onPageChanged,
                      onScrollStart: onScrollStart,
                      onScrollEnd: onScrollEnd,
                    ),
                    NavCommon.buildMenuGrid(petMbtiMenus),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
