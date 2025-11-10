import 'package:flutter/material.dart';

class GaugeCalculatorScreen extends StatefulWidget {
  const GaugeCalculatorScreen({super.key});

  @override
  State<GaugeCalculatorScreen> createState() => _GaugeCalculatorScreenState();
}

class _GaugeCalculatorScreenState extends State<GaugeCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // 코수 계산 변수들
  final TextEditingController _myGaugeStitchController = TextEditingController();
  final TextEditingController _patternGaugeStitchController = TextEditingController();
  final TextEditingController _patternStitchController = TextEditingController();
  double _calculatedStitches = 0;

  // 단수 계산 변수들
  final TextEditingController _myGaugeRowController = TextEditingController();
  final TextEditingController _patternGaugeRowController = TextEditingController();
  final TextEditingController _patternRowController = TextEditingController();
  double _calculatedRows = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _myGaugeStitchController.dispose();
    _patternGaugeStitchController.dispose();
    _patternStitchController.dispose();
    _myGaugeRowController.dispose();
    _patternGaugeRowController.dispose();
    _patternRowController.dispose();
    super.dispose();
  }

  void _calculateStitches() {
    final myGauge = double.tryParse(_myGaugeStitchController.text) ?? 0;
    final patternGauge = double.tryParse(_patternGaugeStitchController.text) ?? 0;
    final patternStitches = double.tryParse(_patternStitchController.text) ?? 0;

    if (myGauge > 0 && patternGauge > 0 && patternStitches > 0) {
      setState(() {
        _calculatedStitches = (patternStitches / patternGauge) * myGauge;
      });
    }
  }

  void _calculateRows() {
    final myGauge = double.tryParse(_myGaugeRowController.text) ?? 0;
    final patternGauge = double.tryParse(_patternGaugeRowController.text) ?? 0;
    final patternRows = double.tryParse(_patternRowController.text) ?? 0;

    if (myGauge > 0 && patternGauge > 0 && patternRows > 0) {
      setState(() {
        _calculatedRows = (patternRows / patternGauge) * myGauge;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('게이지 계산기'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '코수 계산하기'),
            Tab(text: '단수 계산하기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStitchCalculator(),
          _buildRowCalculator(),
        ],
      ),
    );
  }

  Widget _buildStitchCalculator() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '코수 계산 공식',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '내가 떠야할 코수 = (도안 코수 ÷ 도안 게이지 코수) × 내 게이지 코수',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _myGaugeStitchController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '내 게이지 코수 (10cm당)',
              border: OutlineInputBorder(),
              suffixText: '코',
            ),
            onChanged: (_) => _calculateStitches(),
            onTap: () => _scrollToBottom(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patternGaugeStitchController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '도안 게이지 코수 (10cm당)',
              border: OutlineInputBorder(),
              suffixText: '코',
            ),
            onChanged: (_) => _calculateStitches(),
            onTap: () => _scrollToBottom(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patternStitchController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '도안 코수',
              border: OutlineInputBorder(),
              suffixText: '코',
            ),
            onChanged: (_) => _calculateStitches(),
            onTap: () => _scrollToBottom(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF6B35)),
            ),
            child: Column(
              children: [
                const Text(
                  '계산 결과',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_calculatedStitches.toStringAsFixed(1)} 코',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowCalculator() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '단수 계산 공식',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '내가 떠야할 단수 = (도안 단수 ÷ 도안 게이지 단수) × 내 게이지 단수',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _myGaugeRowController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '내 게이지 단수 (10cm당)',
              border: OutlineInputBorder(),
              suffixText: '단',
            ),
            onChanged: (_) => _calculateRows(),
            onTap: () => _scrollToBottom(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patternGaugeRowController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '도안 게이지 단수 (10cm당)',
              border: OutlineInputBorder(),
              suffixText: '단',
            ),
            onChanged: (_) => _calculateRows(),
            onTap: () => _scrollToBottom(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patternRowController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '도안 단수',
              border: OutlineInputBorder(),
              suffixText: '단',
            ),
            onChanged: (_) => _calculateRows(),
            onTap: () => _scrollToBottom(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF6B35)),
            ),
            child: Column(
              children: [
                const Text(
                  '계산 결과',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_calculatedRows.toStringAsFixed(1)} 단',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
