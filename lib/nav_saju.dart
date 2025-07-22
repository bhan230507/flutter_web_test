import 'package:flutter/material.dart';
import 'nav_common.dart';

class NavSaju {
  static Widget buildSajuTab({
    required BuildContext context,
    required TabController sajuTabController,
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
    final List<String> tabs = ['내사주', '개사주'];
    final List<Map<String, dynamic>> humanMenus = [
      {'icon': Icons.auto_stories, 'title': '정통사주', 'subtitle': '사주풀이와 운세'},
      {'icon': Icons.calendar_today, 'title': '신년운', 'subtitle': '2025년 신년운세'},
      {'icon': Icons.style, 'title': '행운코디', 'subtitle': '오늘의 행운 아이템'},
      {'icon': Icons.sports_soccer, 'title': '스포츠 운세', 'subtitle': '스포츠 관련 운세'},
    ];
    final List<Map<String, dynamic>> dogMenus = [
      {'icon': Icons.auto_stories, 'title': '정통사주', 'subtitle': '사주풀이와 운세'},
      {'icon': Icons.calendar_today, 'title': '신년운', 'subtitle': '2025년 신년운세'},
      {'icon': Icons.style, 'title': '행운코디', 'subtitle': '오늘의 행운 아이템'},
      {'icon': Icons.directions_walk, 'title': '산책운세', 'subtitle': '오늘의 산책 운세'},
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

        // TabBar (truly flush left using TabBarTheme)
        Theme(
          data: Theme.of(context).copyWith(
            tabBarTheme: const TabBarThemeData(
              tabAlignment: TabAlignment.start,
            ),
          ),
          child: SizedBox(
            height: 44,
            child: TabBar(
              controller: sajuTabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFE91E63),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
        // TabBarView (only the list changes)
        Expanded(
          child: TabBarView(
            controller: sajuTabController,
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
                    NavCommon.buildMenuGrid(humanMenus),
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
                    NavCommon.buildMenuGrid(dogMenus),
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
