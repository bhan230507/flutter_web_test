import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'user_profile_page.dart';
import 'pet_profile_page.dart';

void main() {
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
        textTheme: GoogleFonts.interTextTheme(),
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
  late TabController _tabController;
  int _currentTabIndex = 0;

  // 선택된 사용자와 애견 정보
  Map<String, dynamic>? _selectedUser;
  Map<String, dynamic>? _selectedPet;

  final List<String> tabs = ['내사주', '개사주'];
  final List<Map<String, dynamic>> chips = [
    {'label': '출석체크', 'icon': Icons.check_circle_outline},
    {'label': '정통사주', 'icon': Icons.auto_stories},
    {'label': '신년운', 'icon': Icons.calendar_today},
    {'label': '행운코디', 'icon': Icons.style},
    {'label': '스포츠 운세', 'icon': Icons.sports_soccer},
  ];
  final List<Map<String, dynamic>> navItems = [
    {'label': '사주', 'icon': Icons.person_outline},
    {'label': '궁합', 'icon': Icons.favorite_border},
    {'label': '타로', 'icon': Icons.style},
    {'label': '설정', 'icon': Icons.settings},
  ];

  final List<Map<String, dynamic>> humanMenus = [
    {
      'icon': Icons.check_circle_outline,
      'title': '출석체크',
      'subtitle': '매일 출석하고 포인트 받기'
    },
    {'icon': Icons.auto_stories, 'title': '정통사주', 'subtitle': '사주풀이와 운세'},
    {'icon': Icons.calendar_today, 'title': '신년운', 'subtitle': '2025년 신년운세'},
    {'icon': Icons.style, 'title': '행운코디', 'subtitle': '오늘의 행운 아이템'},
    {'icon': Icons.sports_soccer, 'title': '스포츠 운세', 'subtitle': '스포츠 관련 운세'},
  ];
  final List<Map<String, dynamic>> dogMenus = [
    {'icon': Icons.pets, 'title': '반려견 운세', 'subtitle': '우리집 강아지 사주'},
    {'icon': Icons.favorite, 'title': '건강운', 'subtitle': '반려견 건강 체크'},
    {'icon': Icons.cake, 'title': '생일운', 'subtitle': '생일별 운세'},
    {'icon': Icons.star, 'title': '성격풀이', 'subtitle': '반려견 성격 분석'},
    {'icon': Icons.group, 'title': '궁합', 'subtitle': '반려견과 궁합보기'},
    {'icon': Icons.school, 'title': '훈련운', 'subtitle': '훈련/교육 운세'},
  ];

  // 24시간 감정 데이터 샘플
  final List<Map<String, dynamic>> emotionData = [
    {'time': '00:00', 'energy': 0.3, 'calm': 0.7, 'stress': 0.2, 'label': '새벽'},
    {'time': '03:00', 'energy': 0.1, 'calm': 0.8, 'stress': 0.3, 'label': ''},
    {'time': '06:00', 'energy': 0.4, 'calm': 0.6, 'stress': 0.2, 'label': '아침'},
    {'time': '09:00', 'energy': 0.8, 'calm': 0.3, 'stress': 0.4, 'label': ''},
    {'time': '12:00', 'energy': 0.9, 'calm': 0.2, 'stress': 0.3, 'label': '점심'},
    {'time': '15:00', 'energy': 0.7, 'calm': 0.4, 'stress': 0.5, 'label': ''},
    {'time': '18:00', 'energy': 0.6, 'calm': 0.5, 'stress': 0.2, 'label': '저녁'},
    {'time': '21:00', 'energy': 0.3, 'calm': 0.8, 'stress': 0.1, 'label': '밤'},
  ];

  final List<String> noticeImages = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
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
    _tabController =
        TabController(length: tabs.length, vsync: this, initialIndex: 1);
    _pageController = PageController();
    _startAutoScroll();
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

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildCurrentTabContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        items: navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item['icon']),
                  label: item['label'],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTabIndex) {
      case 0: // 사주
        return _buildSajuTab();
      case 1: // 궁합
        return _buildCompatibilityTab();
      case 2: // 타로
        return _buildTarotTab();
      case 3: // 설정
        return _buildSettingsTab();
      default:
        return _buildSajuTab();
    }
  }

  Widget _buildSajuTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top right: small notification and profile icons
        Padding(
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
                  // 결과 처리 (선택된 사용자 정보)
                  if (result != null) {
                    setState(() {
                      _selectedUser = result;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedUser != null
                        ? const Color(0xFFE91E63).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.black87, size: 20),
                      if (_selectedUser != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          _selectedUser!['name'],
                          style: GoogleFonts.inter(
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
                    MaterialPageRoute(
                      builder: (context) => const PetProfilePage(),
                    ),
                  );
                  // 결과 처리 (선택된 애견 정보)
                  if (result != null) {
                    setState(() {
                      _selectedPet = result;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedPet != null
                        ? const Color(0xFFE91E63).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets, color: Colors.black87, size: 20),
                      if (_selectedPet != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          _selectedPet!['name'],
                          style: GoogleFonts.inter(
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
            ],
          ),
        ),
        // Below: left-aligned large title
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
          child: Text('라이프코치',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24)),
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
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFE91E63),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.normal, fontSize: 16),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
        // Notice Carousel (below tab, rendered once)
        _buildNoticeCarousel(),
        // TabBarView (only the list changes)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMenuGrid(humanMenus),
                    _buildEmotionCurve(),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMenuGrid(dogMenus),
                    _buildEmotionCurve(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
          child: Text('궁합',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('궁합 서비스 준비 중',
                    style: GoogleFonts.inter(
                        fontSize: 18, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('내궁합, 개궁합 서비스가 곧 제공됩니다',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTarotTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
          child: Text('타로카드',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.style, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('타로카드 서비스 준비 중',
                    style: GoogleFonts.inter(
                        fontSize: 18, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('타로카드 디자인과 액션이 준비 중입니다',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
          child: Text('설정',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('설정 서비스 준비 중',
                    style: GoogleFonts.inter(
                        fontSize: 18, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('사용자 정보, 애견 정보 설정이 준비 중입니다',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _carouselTimer?.cancel();
                } else if (notification is ScrollEndNotification) {
                  _startAutoScroll();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: noticeImages.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentNotice = idx;
                  });
                },
                itemBuilder: (context, idx) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          noticeImages[idx],
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                        // 텍스트 오버레이
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE91E63).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  noticeTexts[idx]['badge']!,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                noticeTexts[idx]['title']!,
                                style: GoogleFonts.inter(
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
                                style: GoogleFonts.inter(
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
                      width: _currentNotice == idx ? 16 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _currentNotice == idx
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

  Widget _buildMenuGrid(List<Map<String, dynamic>> menus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.0, // much shorter cards
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          return _buildMenuItem(menu);
        },
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> menu) {
    return Container(
      // No margin here
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
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
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(menu['icon'], color: const Color(0xFFE91E63), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(menu['title'],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(menu['subtitle'],
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCurve() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: const Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              Text(
                '오늘의 감정 곡선',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 감정 범례
          Row(
            children: [
              _buildLegendItem('에너지', const Color(0xFF4CAF50)),
              const SizedBox(width: 16),
              _buildLegendItem('침착', const Color(0xFF2196F3)),
              const SizedBox(width: 16),
              _buildLegendItem('스트레스', const Color(0xFFFF5722)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() < emotionData.length &&
                            emotionData[value.toInt()]['label']
                                    ?.toString()
                                    .isNotEmpty ==
                                true) {
                          return Text(
                            emotionData[value.toInt()]['label'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: (emotionData.length - 1).toDouble(),
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  // 에너지 라인
                  LineChartBarData(
                    spots: emotionData.asMap().entries.map((entry) {
                      final value = entry.value['energy'] ?? 0.0;
                      return FlSpot(entry.key.toDouble(), value);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // 라벨이 있는 시간대에만 도트 표시
                        if (index < emotionData.length &&
                            emotionData[index]['label']
                                    ?.toString()
                                    .isNotEmpty ==
                                true) {
                          return FlDotCirclePainter(
                            radius: 1.5,
                            color: const Color(0xFF4CAF50),
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // 침착 라인
                  LineChartBarData(
                    spots: emotionData.asMap().entries.map((entry) {
                      final value = entry.value['calm'] ?? 0.0;
                      return FlSpot(entry.key.toDouble(), value);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF2196F3),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // 라벨이 있는 시간대에만 도트 표시
                        if (index < emotionData.length &&
                            emotionData[index]['label']
                                    ?.toString()
                                    .isNotEmpty ==
                                true) {
                          return FlDotCirclePainter(
                            radius: 1.5,
                            color: const Color(0xFF2196F3),
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // 스트레스 라인
                  LineChartBarData(
                    spots: emotionData.asMap().entries.map((entry) {
                      final value = entry.value['stress'] ?? 0.0;
                      return FlSpot(entry.key.toDouble(), value);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFFFF5722),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // 라벨이 있는 시간대에만 도트 표시
                        if (index < emotionData.length &&
                            emotionData[index]['label']
                                    ?.toString()
                                    .isNotEmpty ==
                                true) {
                          return FlDotCirclePainter(
                            radius: 1.5,
                            color: const Color(0xFFFF5722),
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
