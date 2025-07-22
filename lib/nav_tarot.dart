import 'package:flutter/material.dart';
import 'nav_common.dart';

class NavTarot {
  static Widget buildTarotTab({
    required BuildContext context,
    required TabController tarotTabController,
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
    final List<Map<String, dynamic>> tarotMenus = [
      {'icon': Icons.style, 'title': '오늘의 타로', 'subtitle': '일일 운세'},
      {'icon': Icons.favorite, 'title': '연애 타로', 'subtitle': '연애 운세'},
      {'icon': Icons.work, 'title': '직업 타로', 'subtitle': '직업 운세'},
      {'icon': Icons.attach_money, 'title': '금전 타로', 'subtitle': '재물 운세'},
      {'icon': Icons.psychology, 'title': '심리 타로', 'subtitle': '심리 분석'},
      {'icon': Icons.timeline, 'title': '미래 타로', 'subtitle': '미래 예측'},
      {'icon': Icons.healing, 'title': '치유 타로', 'subtitle': '마음 치유'},
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

        // TabBar for tarot
        Theme(
          data: Theme.of(context).copyWith(
            tabBarTheme: const TabBarThemeData(
              tabAlignment: TabAlignment.start,
            ),
          ),
          child: SizedBox(
            height: 44,
            child: TabBar(
              controller: tarotTabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFE91E63),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: ['타로'].map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
        // TabBarView for tarot
        Expanded(
          child: TabBarView(
            controller: tarotTabController,
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
                    NavCommon.buildMenuGrid(tarotMenus),
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
