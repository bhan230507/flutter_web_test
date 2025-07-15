import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as md;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const SajuApp());
}

class SajuApp extends StatelessWidget {
  const SajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사주 운세 분석',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513), // 갈색 테마
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SajuHomePage(),
    );
  }
}

class SajuHomePage extends StatefulWidget {
  const SajuHomePage({super.key});

  @override
  State<SajuHomePage> createState() => _SajuHomePageState();
}

class _SajuHomePageState extends State<SajuHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthTimeController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedGender = '남성';
  String _sessionToken = '';
  String _analysisResult = '';
  bool _isLoading = false;
  bool _isAnalyzing = false;
  bool _autoScrollEnabled = true;
  bool _isLunar = false; // 양력/음력 토글
  bool _birthTimeUnknown = false; // 출생시간 모름
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    // 기본값 설정
    _nameController.text = '한기정';
    _birthDateController.text = '1985-06-23';
    _birthTimeController.text = '06:00';
    _selectedDate = DateTime(1985, 6, 23);
    _selectedTime = const TimeOfDay(hour: 6, minute: 0);

    _initSession();

    // 스크롤 리스너 추가
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse ||
          _scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
        setState(() {
          _autoScrollEnabled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/session/init'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sessionToken = data['session_token'];
        });
      }
    } catch (e) {
      _showError('세션 초기화 실패: $e');
    }
  }

  Future<void> _analyzeSaju() async {
    if (!_formKey.currentState!.validate()) return;

    // 추가 검증
    if (_birthDateController.text.isEmpty) {
      _showError('생년월일을 선택해주세요');
      return;
    }

    if (!_birthTimeUnknown && _birthTimeController.text.isEmpty) {
      _showError('출생시간을 선택해주세요');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
      _autoScrollEnabled = true;
    });

    try {
      final request = http.Request(
        'POST',
        Uri.parse('http://localhost:8000/api/saju/analyze'),
      );

      request.headers['Content-Type'] = 'application/json';
      request.headers['User-Agent'] =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36';
      request.headers['Accept'] = 'application/json';
      request.body = json.encode({
        'name': _nameController.text,
        'birth_date': _birthDateController.text,
        'birth_time': _birthTimeUnknown ? '모름' : _birthTimeController.text,
        'gender': _selectedGender,
        'is_lunar': _isLunar,
      });

      // 디버깅용 로그
      print('전송 데이터:');
      print('이름: ${_nameController.text}');
      print('생년월일: ${_birthDateController.text}');
      print('출생시간: ${_birthTimeUnknown ? '모름' : _birthTimeController.text}');
      print('성별: $_selectedGender');
      print('음력여부: $_isLunar');
      print('출생시간 모름: $_birthTimeUnknown');

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        // 실시간 스트리밍 처리
        String result = '';

        await for (List<int> chunk in streamedResponse.stream) {
          final text = utf8.decode(chunk);
          setState(() {
            result += text;
            _analysisResult = result;
          });

          // 자동 스크롤
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && _autoScrollEnabled) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        final responseBody = await streamedResponse.stream.bytesToString();
        final errorData = json.decode(responseBody);
        _showError('분석 실패: ${errorData['detail']}');
      }
    } catch (e) {
      _showError('분석 오류: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _getKoreanMonth(int month) {
    switch (month) {
      case 1:
        return '1월';
      case 2:
        return '2월';
      case 3:
        return '3월';
      case 4:
        return '4월';
      case 5:
        return '5월';
      case 6:
        return '6월';
      case 7:
        return '7월';
      case 8:
        return '8월';
      case 9:
        return '9월';
      case 10:
        return '10월';
      case 11:
        return '11월';
      case 12:
        return '12월';
      default:
        return '$month월';
    }
  }

  String _formatDateForDisplay(DateTime date) {
    return "${date.year}년 ${_getKoreanMonth(date.month)} ${date.day}일";
  }

  Future<void> _selectDate() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Text(
                      '생년월일 선택',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_selectedDate != null) {
                          setState(() {
                            _birthDateController.text =
                                "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // 년도 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 50,
                        onSelectedItemChanged: (int index) {
                          final year = DateTime.now().year - index;
                          setState(() {
                            _selectedDate = DateTime(
                              year,
                              _selectedDate?.month ?? DateTime.now().month,
                              _selectedDate?.day ?? DateTime.now().day,
                            );
                          });
                        },
                        children: List.generate(124, (index) {
                          final year = DateTime.now().year - index;
                          return Center(
                            child: Text(
                              '$year년',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }),
                      ),
                    ),
                    // 월 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 50,
                        onSelectedItemChanged: (int index) {
                          final month = index + 1;
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate?.year ?? DateTime.now().year,
                              month,
                              _selectedDate?.day ?? DateTime.now().day,
                            );
                          });
                        },
                        children: List.generate(12, (index) {
                          final month = index + 1;
                          return Center(
                            child: Text(
                              _getKoreanMonth(month),
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }),
                      ),
                    ),
                    // 일 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 50,
                        onSelectedItemChanged: (int index) {
                          final day = index + 1;
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate?.year ?? DateTime.now().year,
                              _selectedDate?.month ?? DateTime.now().month,
                              day,
                            );
                          });
                        },
                        children: List.generate(31, (index) {
                          final day = index + 1;
                          return Center(
                            child: Text(
                              '$day일',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Text(
                      '출생시간 선택',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_selectedTime != null) {
                          setState(() {
                            _birthTimeController.text =
                                "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // 시간 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 50,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedTime = TimeOfDay(
                              hour: index,
                              minute: _selectedTime?.minute ?? 0,
                            );
                          });
                        },
                        children: List.generate(24, (index) {
                          return Center(
                            child: Text(
                              '${index.toString().padLeft(2, '0')}시',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }),
                      ),
                    ),
                    // 분 선택
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 50,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedTime = TimeOfDay(
                              hour: _selectedTime?.hour ?? 0,
                              minute: index,
                            );
                          });
                        },
                        children: List.generate(60, (index) {
                          return Center(
                            child: Text(
                              '${index.toString().padLeft(2, '0')}분',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarkdownText(String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    // 마크다운을 HTML로 변환
    final html = md.markdownToHtml(text);

    // HTML을 파싱하여 위젯으로 변환
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: _parseHtmlToWidgets(html),
    );
  }

  Widget _parseHtmlToWidgets(String html) {
    // 간단한 HTML 파싱 (실제로는 더 복잡한 파서가 필요할 수 있음)
    final lines = html.split('\n');
    final widgets = <Widget>[];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('<h1>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        );
      } else if (line.startsWith('<h2>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        );
      } else if (line.startsWith('<h3>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        );
      } else if (line.startsWith('<strong>') || line.startsWith('<b>')) {
        widgets.add(
          Text(
            line.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      } else if (line.startsWith('<ul>') || line.startsWith('<ol>')) {
        // 리스트 처리
        final items = line.split('<li>');
        for (String item in items) {
          if (item.trim().isNotEmpty &&
              !item.startsWith('<ul>') &&
              !item.startsWith('<ol>')) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.replaceAll(RegExp(r'<[^>]*>'), ''),
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      } else {
        // 일반 텍스트
        final cleanText = line.replaceAll(RegExp(r'<[^>]*>'), '');
        if (cleanText.trim().isNotEmpty) {
          widgets.add(
            Text(
              cleanText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          );
        }
      }

      widgets.add(const SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사주 운세 분석'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 앱 소개
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI 운세 분석',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 생년월일과 출생시간을 위로 배치
              Row(
                children: [
                  // 생년월일 카드
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '생년월일',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                // 양력/음력 토글
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _isLunar
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1)
                                            : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _isLunar
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                              : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => _isLunar = false,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                !_isLunar
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '양력',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  !_isLunar
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:
                                            () =>
                                                setState(() => _isLunar = true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                _isLunar
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '음력',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  _isLunar
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[50],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _birthDateController.text.isEmpty
                                            ? '날짜 선택'
                                            : _selectedDate != null
                                            ? _formatDateForDisplay(
                                              _selectedDate!,
                                            )
                                            : _birthDateController.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              _birthDateController.text.isEmpty
                                                  ? Colors.grey[500]
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[600],
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_formKey.currentState?.validate() == false &&
                                _birthDateController.text.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '생년월일을 선택해주세요',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 출생시간 카드
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '출생시간',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                // 출생시간 모름 토글
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _birthTimeUnknown
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1)
                                            : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _birthTimeUnknown
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                              : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _birthTimeUnknown = false;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                !_birthTimeUnknown
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '알림',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  !_birthTimeUnknown
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _birthTimeUnknown = true;
                                            _birthTimeController.clear();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                _birthTimeUnknown
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '모름',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  _birthTimeUnknown
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _birthTimeUnknown ? null : _selectTime,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      _birthTimeUnknown
                                          ? Colors.grey[200]
                                          : Colors.grey[50],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color:
                                          _birthTimeUnknown
                                              ? Colors.grey[400]
                                              : Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _birthTimeUnknown
                                            ? '시간 모름'
                                            : _birthTimeController.text.isEmpty
                                            ? '시간 선택'
                                            : _birthTimeController.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              _birthTimeUnknown
                                                  ? Colors.grey[500]
                                                  : _birthTimeController
                                                      .text
                                                      .isEmpty
                                                  ? Colors.grey[500]
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (!_birthTimeUnknown)
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey[600],
                                        size: 14,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (_formKey.currentState?.validate() == false &&
                                !_birthTimeUnknown &&
                                _birthTimeController.text.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '출생시간을 선택해주세요',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 이름과 성별을 나란히 배치 (7:3 비율)
              Row(
                children: [
                  // 이름 입력 (7)
                  Expanded(
                    flex: 7,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        hintText: '이름을 입력해주세요',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 성별 선택 (3)
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: '성별',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: '남성', child: Text('남성')),
                        DropdownMenuItem(value: '여성', child: Text('여성')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 분석 버튼
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeSaju,
                icon:
                    _isAnalyzing
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.psychology),
                label: Text(_isAnalyzing ? '분석 중...' : '운세 분석하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),

              // 분석 결과
              if (_analysisResult.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '운세 분석 결과',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildMarkdownText(_analysisResult),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
