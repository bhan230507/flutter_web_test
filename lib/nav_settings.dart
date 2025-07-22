import 'package:flutter/material.dart';

class NavSettings {
  static Widget buildSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
          child: Text(
            '설정',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  '설정 서비스 준비 중',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '사용자 정보, 애견 정보 설정이 준비 중입니다',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
