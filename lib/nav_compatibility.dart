import 'package:flutter/material.dart';
import 'nav_common.dart';

class NavCompatibility {
  static Widget buildCompatibilityTab({
    required BuildContext context,
    required TabController compatibilityTabController,
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
    final List<Map<String, dynamic>> humanCompatibilityMenus = [
      {'icon': Icons.favorite, 'title': '연애궁합', 'subtitle': '연인과의 궁합'},
      {'icon': Icons.people, 'title': '친구궁합', 'subtitle': '친구와의 궁합'},
      {'icon': Icons.family_restroom, 'title': '가족궁합', 'subtitle': '가족과의 궁합'},
      {'icon': Icons.work, 'title': '직장궁합', 'subtitle': '동료와의 궁합'},
    ];

    final List<Map<String, dynamic>> petCompatibilityMenus = [
      {'icon': Icons.pets, 'title': '강아지궁합', 'subtitle': '강아지와의 궁합'},
      {'icon': Icons.pets, 'title': '고양이궁합', 'subtitle': '고양이와의 궁합'},
      {'icon': Icons.favorite, 'title': '애완동물궁합', 'subtitle': '다른 애완동물과의 궁합'},
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

        // TabBar for compatibility
        Theme(
          data: Theme.of(context).copyWith(
            tabBarTheme: const TabBarThemeData(
              tabAlignment: TabAlignment.start,
            ),
          ),
          child: SizedBox(
            height: 44,
            child: TabBar(
              controller: compatibilityTabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFE91E63),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: ['인간궁합', '반려동물궁합'].map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
        // TabBarView for compatibility
        Expanded(
          child: TabBarView(
            controller: compatibilityTabController,
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
                    NavCommon.buildMenuGrid(humanCompatibilityMenus),
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
                    NavCommon.buildMenuGrid(petCompatibilityMenus),
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
