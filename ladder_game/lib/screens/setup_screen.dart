import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ladder_game_data.dart';
import 'input_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _participantsController = TextEditingController();

  @override
  void dispose() {
    _participantsController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (_formKey.currentState!.validate()) {
      final numberOfParticipants = int.parse(_participantsController.text);
      // 결과 수도 참가자 수와 동일하게 설정
      final numberOfResults = numberOfParticipants;

      final gameData = LadderGameData(
        numberOfParticipants: numberOfParticipants,
        numberOfResults: numberOfResults,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InputScreen(gameData: gameData),
        ),
      );
    }
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    final number = int.tryParse(value);
    if (number == null || number < 2) {
      return '$fieldName은(는) 2 이상이어야 합니다';
    }
    if (number > 10) {
      return '$fieldName은(는) 10 이하여야 합니다';
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
          '사다리타기 게임',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 게임 아이콘
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.assessment,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 제목
                  const Text(
                    '게임 설정',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '참가자 수를 입력해주세요\n결과 항목 수도 자동으로 동일하게 설정됩니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 참가자 수 입력
                  _buildInputCard(
                    controller: _participantsController,
                    label: '참가자 수',
                    hint: '2-10명',
                    icon: Icons.people,
                    validator: (value) => _validateNumber(value, '참가자 수'),
                  ),
                  const SizedBox(height: 40),

                  // 게임 시작 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.blue.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '게임 시작',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: Colors.blue.shade600,
            ),
            border: InputBorder.none,
            labelStyle: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
