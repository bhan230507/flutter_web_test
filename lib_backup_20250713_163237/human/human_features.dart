import 'package:flutter/cupertino.dart';

class HumanFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const HumanFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

final List<HumanFeature> humanFeatures = [
  HumanFeature(
    icon: CupertinoIcons.person_crop_circle,
    title: '사주 분석',
    subtitle: '운명, 성격, 궁합 등',
    onTap: () {},
  ),
  HumanFeature(
    icon: CupertinoIcons.heart,
    title: '궁합',
    subtitle: '인연의 신비',
    onTap: () {},
  ),
  HumanFeature(
    icon: CupertinoIcons.star,
    title: '운세',
    subtitle: '오늘의 운세',
    onTap: () {},
  ),
  HumanFeature(
    icon: CupertinoIcons.book,
    title: '사주 풀이',
    subtitle: '전문가 해석',
    onTap: () {},
  ),
  HumanFeature(
    icon: CupertinoIcons.person_2,
    title: 'MBTI',
    subtitle: '성격 유형 분석',
    onTap: () {},
  ),
  HumanFeature(
    icon: CupertinoIcons.info,
    title: '내 정보',
    subtitle: '프로필 관리',
    onTap: () {},
  ),
];
