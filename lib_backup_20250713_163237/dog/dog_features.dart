import 'package:flutter/cupertino.dart';

class DogFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const DogFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

final List<DogFeature> dogFeatures = [
  DogFeature(
    icon: CupertinoIcons.paw,
    title: '개 사주 분석',
    subtitle: '반려견 운세, 궁합 등',
    onTap: () {},
  ),
  DogFeature(
    icon: CupertinoIcons.heart,
    title: '궁합',
    subtitle: '반려견과의 인연',
    onTap: () {},
  ),
  DogFeature(
    icon: CupertinoIcons.star,
    title: '운세',
    subtitle: '오늘의 운세',
    onTap: () {},
  ),
  DogFeature(
    icon: CupertinoIcons.book,
    title: '사주 풀이',
    subtitle: '전문가 해석',
    onTap: () {},
  ),
  DogFeature(
    icon: CupertinoIcons.person_2,
    title: '반려견 MBTI',
    subtitle: '반려견 성격 분석',
    onTap: () {},
  ),
  DogFeature(
    icon: CupertinoIcons.info,
    title: '반려견 정보',
    subtitle: '프로필 관리',
    onTap: () {},
  ),
];
