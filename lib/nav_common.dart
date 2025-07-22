import 'package:flutter/material.dart';
import 'profile_user.dart';
import 'profile_pet.dart';
import 'globals.dart';

class NavCommon {
  static Widget buildProfileIcons({
    required BuildContext context,
    required Map<String, dynamic>? selectedUser,
    required Map<String, dynamic>? selectedPet,
    required Function(Map<String, dynamic>) onUserSelected,
    required Function(Map<String, dynamic>) onPetSelected,
    required VoidCallback onKakaoLogin,
    required VoidCallback onLogout, // 로그아웃 콜백 추가
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
              if (result != null) {
                onUserSelected(result);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selectedUser != null
                    ? const Color(0xFFE91E63).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.black87, size: 20),
                  if (selectedUser != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      selectedUser!['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PetProfilePage()),
              );
              if (result != null) {
                onPetSelected(result);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selectedPet != null
                    ? const Color(0xFFE91E63).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pets, color: Colors.black87, size: 20),
                  if (selectedPet != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      selectedPet!['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 로그인 상태에 따라 버튼 표시
          if (!Globals.isLoggedIn()) ...[
            // 로그인되지 않은 경우: 카카오 로그인 버튼
            GestureDetector(
              onTap: onKakaoLogin,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE500), // 카카오 브랜드 색상
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFEE500), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3C1E1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // 로그인된 경우: 프로필 + 닉네임 + 로그아웃 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFEE500), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (Globals.getLoggedInUser()?['user_info']['profile_image'] !=
                      null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        Globals.getLoggedInUser()!['user_info']['profile_image'],
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: const Color(0xFF3C1E1E),
                            size: 20,
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.person,
                      color: const Color(0xFF3C1E1E),
                      size: 20,
                    ),
                  ],
                  const SizedBox(width: 4),
                  Text(
                    Globals.getLoggedInUser()?['user_info']['nickname'] ??
                        '사용자',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3C1E1E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onLogout,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(Icons.logout, color: Colors.red, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildNoticeCarousel({
    required BuildContext context,
    required List<String> noticeImages,
    required List<Map<String, String>> noticeTexts,
    required PageController pageController,
    required int currentNotice,
    required Function(int) onPageChanged,
    required VoidCallback onScrollStart,
    required VoidCallback onScrollEnd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 107,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  onScrollStart();
                } else if (notification is ScrollEndNotification) {
                  onScrollEnd();
                }
                return false;
              },
              child: PageView.builder(
                controller: pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: noticeImages.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, idx) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.asset(
                          noticeImages[idx],
                          width: double.infinity,
                          height: 107,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE91E63,
                                  ).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  noticeTexts[idx]['badge']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                noticeTexts[idx]['title']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                noticeTexts[idx]['subtitle']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    noticeImages.length,
                    (idx) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentNotice == idx ? 16 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: currentNotice == idx
                            ? Colors.white.withOpacity(0.85)
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildMenuGrid(List<Map<String, dynamic>> menus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.0,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          return buildMenuItem(menu);
        },
      ),
    );
  }

  static Widget buildMenuItem(Map<String, dynamic> menu) {
    final bool isEnabled = menu['enabled'] ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled ? Colors.grey.shade200 : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isEnabled ? 0.04 : 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isEnabled ? Colors.grey.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              menu['icon'],
              color: isEnabled ? const Color(0xFFE91E63) : Colors.grey.shade400,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  menu['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isEnabled ? Colors.black : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  menu['subtitle'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isEnabled ? Colors.grey : Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
