import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final List<Map<String, dynamic>> users = [
    {
      'name': '김철수',
      'birthDate': '1990-03-15',
      'birthTime': '14:30',
      'isLunar': false,
      'isMale': true,
      'mbti': 'ENFP',
      'bloodType': 'A',
      'zodiac': '물고기자리',
      'chineseZodiac': '말띠',
      'isSelected': true,
    },
    {
      'name': '이영희',
      'birthDate': '1988-07-22',
      'birthTime': null,
      'isLunar': false,
      'isMale': false,
      'mbti': 'ISTJ',
      'bloodType': 'O',
      'zodiac': '사자자리',
      'chineseZodiac': '용띠',
      'isSelected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '사용자 정보',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 기존 사용자 목록
          if (users.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.person, color: const Color(0xFFE91E63), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '등록된 사용자',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['isSelected']
                          ? const Color(0xFFE91E63).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: user['isSelected']
                            ? const Color(0xFFE91E63)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFFE91E63).withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: const Color(0xFFE91E63),
                        ),
                      ),
                      title: Text(
                        user['name'],
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${user['birthDate']} • ${user['zodiac']} • ${user['chineseZodiac']} • ${user['isMale'] ? '남' : '여'}${user['mbti'] != null ? ' • ${user['mbti']}' : ''}${user['bloodType'] != null ? ' • ${user['bloodType']}형' : ''}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user['isSelected'])
                            Icon(Icons.check_circle,
                                color: const Color(0xFFE91E63)),
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: Colors.grey.shade600, size: 20),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddUserPage(editingUser: user),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  users[index] = result;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          for (var u in users) {
                            u['isSelected'] = false;
                          }
                          user['isSelected'] = true;
                        });
                        Navigator.pop(context, user);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
          // 새 사용자 추가 버튼
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddUserPage(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      users.add(result);
                    });
                  }
                },
                icon: Icon(Icons.add),
                label: Text('새 사용자 추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddUserPage extends StatefulWidget {
  final Map<String, dynamic>? editingUser;

  const AddUserPage({super.key, this.editingUser});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool _isLunar = false;
  bool _isMale = true; // 남녀 토글 추가
  String? _zodiacSign;
  String? _chineseZodiac;
  String? _selectedMbti; // MBTI 선택
  String? _selectedBloodType; // 혈액형 선택

  // MBTI 옵션들
  final List<String> mbtiOptions = [
    'ISTJ',
    'ISFJ',
    'INFJ',
    'INTJ',
    'ISTP',
    'ISFP',
    'INFP',
    'INTP',
    'ESTP',
    'ESFP',
    'ENFP',
    'ENTP',
    'ESTJ',
    'ESFJ',
    'ENFJ',
    'ENTJ'
  ];

  // 혈액형 옵션들
  final List<String> bloodTypeOptions = ['A', 'B', 'O', 'AB'];

  final Map<String, String> zodiacSigns = {
    '물고기자리': '2월 19일 - 3월 20일',
    '양자리': '3월 21일 - 4월 19일',
    '황소자리': '4월 20일 - 5월 20일',
    '쌍둥이자리': '5월 21일 - 6월 21일',
    '게자리': '6월 22일 - 7월 22일',
    '사자자리': '7월 23일 - 8월 22일',
    '처녀자리': '8월 23일 - 9월 22일',
    '천칭자리': '9월 23일 - 10월 22일',
    '전갈자리': '10월 23일 - 11월 21일',
    '사수자리': '11월 22일 - 12월 21일',
    '염소자리': '12월 22일 - 1월 19일',
    '물병자리': '1월 20일 - 2월 18일',
  };

  final Map<String, String> chineseZodiacs = {
    '쥐띠': '2020, 2008, 1996, 1984, 1972, 1960',
    '소띠': '2021, 2009, 1997, 1985, 1973, 1961',
    '호랑이띠': '2022, 2010, 1998, 1986, 1974, 1962',
    '토끼띠': '2023, 2011, 1999, 1987, 1975, 1963',
    '용띠': '2024, 2012, 2000, 1988, 1976, 1964',
    '뱀띠': '2025, 2013, 2001, 1989, 1977, 1965',
    '말띠': '2026, 2014, 2002, 1990, 1978, 1966',
    '양띠': '2027, 2015, 2003, 1991, 1979, 1967',
    '원숭이띠': '2028, 2016, 2004, 1992, 1980, 1968',
    '닭띠': '2029, 2017, 2005, 1993, 1981, 1969',
    '개띠': '2030, 2018, 2006, 1994, 1982, 1970',
    '돼지띠': '2031, 2019, 2007, 1995, 1983, 1971',
  };

  @override
  void initState() {
    super.initState();
    if (widget.editingUser != null) {
      _nameController.text = widget.editingUser!['name'];
      _dateController.text = widget.editingUser!['birthDate'];
      _timeController.text = widget.editingUser!['birthTime'] ?? '';
      _isLunar = widget.editingUser!['isLunar'] ?? false;
      _isMale = widget.editingUser!['isMale'] ?? true; // 남녀 정보 추가
      _selectedMbti = widget.editingUser!['mbti']; // MBTI 정보 추가
      _selectedBloodType = widget.editingUser!['bloodType']; // 혈액형 정보 추가
      _calculateZodiacSigns(_dateController.text);
    }
  }

  void _calculateZodiacSigns(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        // 음력인 경우 양력으로 변환 (간단한 근사치)
        int solarYear = year;
        int solarMonth = month;
        int solarDay = day;

        if (_isLunar) {
          // 음력 → 양력 변환 (간단한 근사치)
          // 실제로는 더 복잡한 계산이 필요하지만, 여기서는 기본적인 변환만 구현
          if (month == 1) {
            solarMonth = 2;
            solarDay = day + 15; // 음력 1월은 양력 2월 중순경
          } else if (month == 2) {
            solarMonth = 3;
            solarDay = day + 10;
          } else if (month == 3) {
            solarMonth = 4;
            solarDay = day + 5;
          } else if (month == 4) {
            solarMonth = 5;
            solarDay = day;
          } else if (month == 5) {
            solarMonth = 6;
            solarDay = day - 5;
          } else if (month == 6) {
            solarMonth = 7;
            solarDay = day - 10;
          } else if (month == 7) {
            solarMonth = 8;
            solarDay = day - 15;
          } else if (month == 8) {
            solarMonth = 9;
            solarDay = day - 20;
          } else if (month == 9) {
            solarMonth = 10;
            solarDay = day - 25;
          } else if (month == 10) {
            solarMonth = 11;
            solarDay = day - 30;
          } else if (month == 11) {
            solarMonth = 12;
            solarDay = day - 35;
          } else if (month == 12) {
            solarYear = year + 1;
            solarMonth = 1;
            solarDay = day - 40;
          }

          // 날짜 보정
          if (solarDay <= 0) {
            solarMonth--;
            solarDay += 30;
          }
          if (solarMonth <= 0) {
            solarYear--;
            solarMonth = 12;
          }
        }

        // 별자리 계산 (양력 기준)
        if ((solarMonth == 3 && solarDay >= 21) ||
            (solarMonth == 4 && solarDay <= 19)) {
          _zodiacSign = '양자리';
        } else if ((solarMonth == 4 && solarDay >= 20) ||
            (solarMonth == 5 && solarDay <= 20)) {
          _zodiacSign = '황소자리';
        } else if ((solarMonth == 5 && solarDay >= 21) ||
            (solarMonth == 6 && solarDay <= 21)) {
          _zodiacSign = '쌍둥이자리';
        } else if ((solarMonth == 6 && solarDay >= 22) ||
            (solarMonth == 7 && solarDay <= 22)) {
          _zodiacSign = '게자리';
        } else if ((solarMonth == 7 && solarDay >= 23) ||
            (solarMonth == 8 && solarDay <= 22)) {
          _zodiacSign = '사자자리';
        } else if ((solarMonth == 8 && solarDay >= 23) ||
            (solarMonth == 9 && solarDay <= 22)) {
          _zodiacSign = '처녀자리';
        } else if ((solarMonth == 9 && solarDay >= 23) ||
            (solarMonth == 10 && solarDay <= 22)) {
          _zodiacSign = '천칭자리';
        } else if ((solarMonth == 10 && solarDay >= 23) ||
            (solarMonth == 11 && solarDay <= 21)) {
          _zodiacSign = '전갈자리';
        } else if ((solarMonth == 11 && solarDay >= 22) ||
            (solarMonth == 12 && solarDay <= 21)) {
          _zodiacSign = '사수자리';
        } else if ((solarMonth == 12 && solarDay >= 22) ||
            (solarMonth == 1 && solarDay <= 19)) {
          _zodiacSign = '염소자리';
        } else if ((solarMonth == 1 && solarDay >= 20) ||
            (solarMonth == 2 && solarDay <= 18)) {
          _zodiacSign = '물병자리';
        } else {
          _zodiacSign = '물고기자리';
        }

        // 띠 계산 (올바른 12간지 순환)
        final zodiacSigns = [
          '쥐띠',
          '소띠',
          '호랑이띠',
          '토끼띠',
          '용띠',
          '뱀띠',
          '말띠',
          '양띠',
          '원숭이띠',
          '닭띠',
          '개띠',
          '돼지띠'
        ];

        // 2020년이 쥐띠이므로 기준으로 계산
        final baseYear = 2020;
        final index = (year - baseYear) % 12;
        _chineseZodiac = zodiacSigns[index < 0 ? index + 12 : index];
      }
    } catch (e) {
      // 날짜 형식이 잘못된 경우 처리
      _zodiacSign = null;
      _chineseZodiac = null;
    }
  }

  bool _isValidDateFormat(String date) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(date)) return false;

    try {
      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      if (year < 1900 || year > DateTime.now().year) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isValidTimeFormat(String time) {
    if (time.isEmpty) return true; // 시간은 선택사항
    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(time)) return false;

    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23) return false;
      if (minute < 0 || minute > 59) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // 날짜 형식 자동 변환
  void _formatDate(String input) {
    // 숫자만 추출
    final numbers = input.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.length >= 8) {
      final year = numbers.substring(0, 4);
      final month = numbers.substring(4, 6);
      final day = numbers.substring(6, 8);
      _dateController.text = '$year-$month-$day';
      _dateController.selection = TextSelection.fromPosition(
        TextPosition(offset: _dateController.text.length),
      );
      _calculateZodiacSigns(_dateController.text);
      setState(() {});
    }
  }

  // 시간 형식 자동 변환
  void _formatTime(String input) {
    // 숫자만 추출
    final numbers = input.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.length >= 4) {
      final hour = numbers.substring(0, 2);
      final minute = numbers.substring(2, 4);
      _timeController.text = '$hour:$minute';
      _timeController.selection = TextSelection.fromPosition(
        TextPosition(offset: _timeController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.editingUser != null ? '사용자 수정' : '새 사용자 추가',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 이름 입력과 남녀 토글
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 남녀 토글 (양력/음력 토글과 같은 크기로 조정)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMale = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          decoration: BoxDecoration(
                            color: _isMale
                                ? Colors.blue // 남성은 파란색
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            '남성',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isMale ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMale = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isMale
                                ? const Color(0xFFE91E63)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            '여성',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: !_isMale
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 생년월일, 시간, 양력/음력 한 줄에 배치
            Row(
              children: [
                // 생년월일
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: '생년월일',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    onChanged: (value) {
                      _formatDate(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '생년월일을 입력해주세요';
                      }
                      if (!_isValidDateFormat(value)) {
                        return '올바른 형식으로 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 시간
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: '시간(옵션)',
                      labelStyle: GoogleFonts.inter(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.access_time, size: 18),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    style: GoogleFonts.inter(fontSize: 12),
                    onChanged: (value) {
                      _formatTime(value);
                    },
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !_isValidTimeFormat(value)) {
                        return '올바른 형식으로 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 양력/음력 토글 (더 작게)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLunar = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isLunar
                                ? const Color(0xFFE91E63) // 양력은 현재 색상 유지
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            '양력',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: !_isLunar
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLunar = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          decoration: BoxDecoration(
                            color: _isLunar
                                ? Colors.blue // 음력은 파란색
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            '음력',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _isLunar
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // MBTI 선택 (4x4 그리드)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'MBTI (옵션)',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 3.5, // 높이 줄임 (2.0 → 3.5)
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: mbtiOptions.length,
                    itemBuilder: (context, index) {
                      final mbti = mbtiOptions[index];
                      final isSelected = _selectedMbti == mbti;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMbti = _selectedMbti == mbti ? null : mbti;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE91E63).withOpacity(0.1)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE91E63)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              mbti,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFFE91E63)
                                    : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 혈액형 선택
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bloodtype, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        '혈액형 (옵션)',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: bloodTypeOptions.map((bloodType) {
                      final isSelected = _selectedBloodType == bloodType;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBloodType =
                                  _selectedBloodType == bloodType
                                      ? null
                                      : bloodType;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE91E63).withOpacity(0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE91E63)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${bloodType}형',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFFE91E63)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 별자리와 띠 표시 (양옆으로 배치)
            if (_zodiacSign != null || _chineseZodiac != null) ...[
              Row(
                children: [
                  // 별자리 표시
                  if (_zodiacSign != null) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: const Color(0xFFE91E63)),
                            const SizedBox(width: 12),
                            Text(
                              '별자리: $_zodiacSign',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE91E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // 간격
                  if (_zodiacSign != null && _chineseZodiac != null)
                    const SizedBox(width: 8),
                  // 띠 표시
                  if (_chineseZodiac != null) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.pets, color: const Color(0xFFE91E63)),
                            const SizedBox(width: 12),
                            Text(
                              '띠: $_chineseZodiac',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE91E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newUser = {
                      'name': _nameController.text,
                      'birthDate': _dateController.text,
                      'birthTime': _timeController.text.isNotEmpty
                          ? _timeController.text
                          : null,
                      'isLunar': _isLunar,
                      'isMale': _isMale, // 남녀 정보 추가
                      'mbti': _selectedMbti, // MBTI 정보 추가
                      'bloodType': _selectedBloodType, // 혈액형 정보 추가
                      'zodiac': _zodiacSign,
                      'chineseZodiac': _chineseZodiac,
                      'isSelected': false,
                    };
                    Navigator.pop(context, newUser);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
