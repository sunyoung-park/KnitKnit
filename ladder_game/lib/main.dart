import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const LadderGameApp());
}

class LadderGameApp extends StatelessWidget {
  const LadderGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사다리타기 게임',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Noto Sans KR',
      ),
      home: const SetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}