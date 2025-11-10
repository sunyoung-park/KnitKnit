import 'package:flutter/material.dart';
import '../models/ladder_game_data.dart';
import 'ladder_game_screen.dart';

class InputScreen extends StatefulWidget {
  final LadderGameData gameData;

  const InputScreen({super.key, required this.gameData});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _participantControllers;
  late List<TextEditingController> _resultControllers;

  @override
  void initState() {
    super.initState();
    _participantControllers = List.generate(
      widget.gameData.numberOfParticipants,
      (index) => TextEditingController(
        text: widget.gameData.participants[index], // 기본값 설정
      ),
    );
    _resultControllers = List.generate(
      widget.gameData.numberOfResults,
      (index) => TextEditingController(
        text: widget.gameData.results[index], // 기본값 설정
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _participantControllers) {
      controller.dispose();
    }
    for (var controller in _resultControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _createLadder() {
    if (_formKey.currentState!.validate()) {
      // 데이터 저장
      for (int i = 0; i < _participantControllers.length; i++) {
        widget.gameData.setParticipant(i, _participantControllers[i].text.trim());
      }
      for (int i = 0; i < _resultControllers.length; i++) {
        widget.gameData.setResult(i, _resultControllers[i].text.trim());
      }

      // 사다리 생성
      widget.gameData.generateLadder();

      // 게임 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LadderGameScreen(gameData: widget.gameData),
        ),
      );
    }
  }

  String? _validateInput(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    
    // 참가자 이름은 6자, 결과 항목은 10자 제한
    final maxLength = fieldName.contains('참가자') ? 6 : 10;
    if (value.trim().length > maxLength) {
      return '$fieldName은(는) ${maxLength}자 이하로 입력해주세요';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          '참가자 및 결과 입력',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 참가자 섹션
                        _buildSectionHeader(
                          '참가자 이름',
                          Icons.people,
                          '${widget.gameData.numberOfParticipants}명',
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                          widget.gameData.numberOfParticipants,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildInputCard(
                              controller: _participantControllers[index],
                              label: '참가자 ${index + 1}',
                              hint: '이름을 입력하세요',
                              validator: (value) => _validateInput(value, '참가자 이름'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 결과 항목 섹션
                        _buildSectionHeader(
                          '결과 항목',
                          Icons.emoji_events,
                          '${widget.gameData.numberOfResults}개',
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                          widget.gameData.numberOfResults,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildInputCard(
                              controller: _resultControllers[index],
                              label: '결과 ${index + 1}',
                              hint: '결과 항목을 입력하세요',
                              validator: (value) => _validateInput(value, '결과 항목'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 사다리 생성 버튼
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _createLadder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.green.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino, size: 24),
                          SizedBox(width: 8),
                          Text(
                            '사다리 생성',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    // 참가자 이름인지 확인하여 글자 수 제한 설정
    final maxLength = label.contains('참가자') ? 6 : 10;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          validator: validator,
          maxLength: maxLength,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: InputBorder.none,
            counterText: '', // 글자수 카운터 숨기기
            labelStyle: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
