import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blur/flutter_blur.dart';
import 'package:blur_container/blur_container.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'human/human_features.dart';
import 'dog/dog_features.dart';

void main() {
  runApp(const SajuApp());
}

class SajuApp extends StatelessWidget {
  const SajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Style Saju',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE4405F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE4405F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      themeMode: ThemeMode.dark,
      home: const AppleStyleMainPage(),
    );
  }
}

class AppleStyleMainPage extends StatelessWidget {
  const AppleStyleMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
              ),
            ),
          ),
          title: Text(
            '사주',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1.2,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE4405F).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.gear,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: const Color(0xFFE4405F),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: '사람 사주', icon: Icon(CupertinoIcons.person, size: 20)),
              Tab(text: '개 사주', icon: Icon(CupertinoIcons.paw, size: 20)),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000000), Color(0xFF1A1A1A), Color(0xFF000000)],
            ),
          ),
          child: TabBarView(
            children: [
              _FeatureGrid(isHuman: true),
              _FeatureGrid(isHuman: false),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A1A).withOpacity(0.95),
                const Color(0xFF000000).withOpacity(0.98),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE4405F).withOpacity(0.2),
                width: 1.0,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFE4405F),
            unselectedItemColor: Colors.white54,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home, size: 24),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book, size: 24),
                label: '사주',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.heart, size: 24),
                label: '궁합',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person, size: 24),
                label: '내 정보',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final bool isHuman;
  const _FeatureGrid({required this.isHuman});

  @override
  Widget build(BuildContext context) {
    final features = isHuman ? humanFeatures : dogFeatures;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: GridView.builder(
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, idx) {
          if (isHuman) {
            final f = features[idx] as HumanFeature;
            return _FeatureCard(
              icon: f.icon,
              title: f.title,
              subtitle: f.subtitle,
              onTap: f.onTap,
              isDark: true,
            );
          } else {
            final f = features[idx] as DogFeature;
            return _FeatureCard(
              icon: f.icon,
              title: f.title,
              subtitle: f.subtitle,
              onTap: f.onTap,
              isDark: true,
            );
          }
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4405F).withOpacity(0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE4405F).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE4405F), Color(0xFF833AB4)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE4405F).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AppleFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
