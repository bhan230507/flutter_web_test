import 'package:flutter/material.dart';
import 'nav_common.dart';
import 'screens/board_list_screen.dart';

class NavBoard {
  static Widget buildBoardTab({
    required BuildContext context,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top right: profile icons (다른 네비게이션과 동일)
        NavCommon.buildProfileIcons(
          context: context,
          selectedUser: selectedUser,
          selectedPet: selectedPet,
          onUserSelected: onUserSelected,
          onPetSelected: onPetSelected,
          onKakaoLogin: onKakaoLogin,
          onLogout: onLogout,
        ),

        // 게시판 내용 (앱바 없이)
        const Expanded(child: BoardListScreen()),
      ],
    );
  }
}
