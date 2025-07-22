import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:google_fonts/google_fonts.dart';

class PetProfilePage extends StatefulWidget {
  const PetProfilePage({super.key});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final List<Map<String, dynamic>> pets = [
    {
      'name': '멍멍이',
      'type': '강아지',
      'breed': '골든리트리버',
      'birthDate': '2020-05-15',
      'birthTime': '09:30',
      'isLunar': false,
      'isMale': true,
      'mbti': 'ENFP',
      'bloodType': 'DEA 1.1+',
      'zodiac': '황소자리',
      'chineseZodiac': '쥐띠', // 2020년 = 쥐띠
      'isSelected': true,
    },
    {
      'name': '냥냥이',
      'type': '고양이',
      'breed': '페르시안',
      'birthDate': '2021-08-22',
      'birthTime': null,
      'isLunar': false,
      'isMale': false,
      'mbti': 'ISTJ',
      'bloodType': 'A형',
      'zodiac': '사자자리',
      'chineseZodiac': '소띠', // 2021년 = 소띠
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
          '애견 정보',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 기존 애견 목록
          if (pets.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.pets, color: const Color(0xFFE91E63), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '등록된 애견',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: pet['isSelected']
                          ? const Color(0xFFE91E63).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pet['isSelected']
                            ? const Color(0xFFE91E63)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFFE91E63,
                        ).withOpacity(0.1),
                        child: Icon(
                          pet['type'] == '강아지' ? Icons.pets : Icons.pets,
                          color: const Color(0xFFE91E63),
                        ),
                      ),
                      title: Text(
                        pet['name'],
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${pet['type']} • ${pet['breed']} • ${pet['birthDate']} • ${pet['isMale'] ? '수컷' : '암컷'}${pet['mbti'] != null ? ' • ${pet['mbti']}' : ''}${pet['bloodType'] != null ? ' • ${pet['bloodType']}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pet['isSelected'])
                            Icon(
                              Icons.check_circle,
                              color: const Color(0xFFE91E63),
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddPetPage(editingPet: pet),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  pets[index] = result;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          for (var p in pets) {
                            p['isSelected'] = false;
                          }
                          pet['isSelected'] = true;
                        });
                        Navigator.pop(context, pet);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
          // 새 애견 추가 버튼
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPetPage()),
                  );
                  if (result != null) {
                    setState(() {
                      pets.add(result);
                    });
                  }
                },
                icon: Icon(Icons.add),
                label: Text('새 애견 추가'),
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

class AddPetPage extends StatefulWidget {
  final Map<String, dynamic>? editingPet;

  const AddPetPage({super.key, this.editingPet});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String _selectedType = '강아지';
  String? _selectedBreed;
  bool _isLunar = false;
  bool _isMale = true; // 수컷/암컷 토글 추가
  String? _zodiacSign;
  String? _chineseZodiac;
  String? _selectedMbti; // MBTI 선택
  String? _selectedBloodType; // 혈액형 선택
  List<File> _petImages = []; // 애견 사진 리스트
  final ImagePicker _picker = ImagePicker();

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
    'ENTJ',
  ];

  // 혈액형 옵션들 (애완동물용)
  List<String> get bloodTypeOptions {
    if (_selectedType == '강아지') {
      return [
        'DEA 1.1+',
        'DEA 1.1-',
        'DEA 1.2',
        'DEA 3',
        'DEA 4',
        'DEA 5',
        'DEA 6',
        'DEA 7',
        'DEA 8',
      ];
    } else {
      return ['A형', 'B형', 'AB형'];
    }
  }

  final Map<String, List<String>> breeds = {
    '강아지': [
      '골든리트리버',
      '래브라도리트리버',
      '진돗개',
      '말티즈',
      '푸들',
      '치와와',
      '포메라니안',
      '시바견',
      '허스키',
      '불독',
      '비글',
      '달마시안',
      '세인트버나드',
      '버니즈마운틴독',
      '콜리',
      '보더콜리',
      '시베리안허스키',
    ],
    '고양이': [
      '페르시안',
      '샴',
      '러시안블루',
      '메인쿤',
      '뱅갈',
      '스핑크스',
      '브리티시숏헤어',
      '아메리칸숏헤어',
      '터키시앙고라',
      '노르웨이숏포레스트',
      '스코티시폴드',
      '먼치킨',
      '라가머핀',
      '이집션마우',
      '아비시니안',
    ],
  };

  List<String> get sortedBreeds {
    final breedList = breeds[_selectedType] ?? [];
    breedList.sort(); // 내림차순 정렬
    return breedList;
  }

  // 이미지 선택 메서드
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          if (_petImages.length < 3) {
            _petImages.add(File(image.path));
          } else {
            // 이미 3장이 있으면 마지막 것을 교체
            _petImages[_petImages.length - 1] = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')));
    }
  }

  // 이미지 삭제 메서드
  void _removeImage(int index) {
    setState(() {
      _petImages.removeAt(index);
    });
  }

  // 이미지 선택 다이얼로그
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사진 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingPet != null) {
      _nameController.text = widget.editingPet!['name'];
      _selectedType = widget.editingPet!['type'];
      _selectedBreed = widget.editingPet!['breed'];
      _dateController.text = widget.editingPet!['birthDate'];
      _timeController.text = widget.editingPet!['birthTime'] ?? '';
      _isLunar = widget.editingPet!['isLunar'] ?? false;
      _isMale = widget.editingPet!['isMale'] ?? true; // 수컷/암컷 정보 추가
      _selectedMbti = widget.editingPet!['mbti']; // MBTI 정보 추가
      _selectedBloodType = widget.editingPet!['bloodType']; // 혈액형 정보 추가
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
          '돼지띠',
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

      if (year < 2000 || year > DateTime.now().year) return false;
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
          widget.editingPet != null ? '애견 수정' : '새 애견 추가',
          style: TextStyle(
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
            // 애견 사진 섹션
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.photo_camera,
                        color: const Color(0xFFE91E63),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '애견 사진',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    child: Row(
                      children: List.generate(3, (index) {
                        final hasImage = index < _petImages.length;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                            decoration: BoxDecoration(
                              color: hasImage
                                  ? Colors.grey.shade100
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasImage
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: hasImage
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.file(
                                          _petImages[index],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _petImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      // 사진 추가 다이얼로그 표시
                                      _showImagePickerDialog();
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          color: Colors.grey.shade400,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '사진 추가',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            // 이름 입력과 수컷/암컷 토글
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '애견 이름',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '애견 이름을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 수컷/암컷 토글
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
                            horizontal: 8,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _isMale
                                ? Colors
                                      .blue // 수컷은 파란색
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            '수컷',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _isMale
                                  ? Colors.white
                                  : Colors.grey.shade600,
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
                            horizontal: 8,
                            vertical: 16,
                          ),
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
                            '암컷',
                            style: TextStyle(
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
                  flex: 1,
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: '생년월일',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // prefixIcon: Icon(Icons.calendar_today, size: 18),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(fontSize: 12),
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
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // prefixIcon: Icon(Icons.access_time, size: 16),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                    ),
                    style: TextStyle(fontSize: 12),
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
                            horizontal: 8,
                            vertical: 16,
                          ),
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
                            style: TextStyle(
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
                            horizontal: 8,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _isLunar
                                ? Colors
                                      .blue // 음력은 파란색
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            '음력',
                            style: TextStyle(
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

            // 종류 선택 (강아지/고양이)
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
                      Icon(Icons.pets, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        '종류 선택',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['강아지', '고양이'].map((String type) {
                      final isSelected = _selectedType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = type;
                              _selectedBreed = null; // 품종 초기화
                              _selectedBloodType = null; // 혈액형 초기화
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                                type,
                                style: TextStyle(
                                  fontSize: 12,
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

            // 품종 선택 (3열 그리드)
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
                      Icon(Icons.category, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        '품종 선택',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3.5, // 높이 줄임 (2.5 → 3.5)
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemCount: sortedBreeds.length,
                    itemBuilder: (context, index) {
                      final breed = sortedBreeds[index];
                      final isSelected = _selectedBreed == breed;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedBreed = breed;
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
                              breed,
                              style: TextStyle(
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
                        style: TextStyle(fontWeight: FontWeight.w500),
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
                          childAspectRatio: 2.5, // 높이 늘림 (3.5 → 2.5)
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
                              style: TextStyle(
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
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 강아지인 경우 3x3 그리드, 고양이인 경우 가로 배치
                  if (_selectedType == '강아지') ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 3.5, // 높이 줄임 (2.5 → 3.5)
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                      itemCount: bloodTypeOptions.length,
                      itemBuilder: (context, index) {
                        final bloodType = bloodTypeOptions[index];
                        final isSelected = _selectedBloodType == bloodType;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedBloodType =
                                  _selectedBloodType == bloodType
                                  ? null
                                  : bloodType;
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
                                bloodType,
                                style: TextStyle(
                                  fontSize: 10,
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
                  ] else ...[
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
                                  bloodType,
                                  style: TextStyle(
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
                              '$_zodiacSign',
                              style: TextStyle(
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
                              '$_chineseZodiac',
                              style: TextStyle(
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
                  if (_formKey.currentState!.validate() &&
                      _selectedBreed != null) {
                    final newPet = {
                      'name': _nameController.text,
                      'type': _selectedType,
                      'breed': _selectedBreed,
                      'birthDate': _dateController.text,
                      'birthTime': _timeController.text.isNotEmpty
                          ? _timeController.text
                          : null,
                      'isLunar': _isLunar,
                      'isMale': _isMale, // 수컷/암컷 정보 추가
                      'mbti': _selectedMbti, // MBTI 정보 추가
                      'bloodType': _selectedBloodType, // 혈액형 정보 추가
                      'zodiac': _zodiacSign,
                      'chineseZodiac': _chineseZodiac,
                      'isSelected': false,
                    };
                    Navigator.pop(context, newPet);
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
