import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/ladder_game_data.dart';
import '../widgets/ladder_painter.dart';

class LadderGameScreen extends StatefulWidget {
  final LadderGameData gameData;

  const LadderGameScreen({super.key, required this.gameData});

  @override
  State<LadderGameScreen> createState() => _LadderGameScreenState();
}

class _LadderGameScreenState extends State<LadderGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  List<Offset> _animationPath = [];
  bool _isAnimating = false;
  int? _selectedParticipant;
  String? _result;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showResult = true;
        });
        // 애니메이션 완료 후 팝업 표시
        Future.delayed(const Duration(milliseconds: 500), () {
          _showResultPopup();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startLadderGame(int participantIndex) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _selectedParticipant = participantIndex;
      _showResult = false;
    });

    // 사다리 경로 계산
    _calculateAnimationPath(participantIndex);
    
    // 결과 계산
    final resultIndex = widget.gameData.followLadderPath(participantIndex);
    _result = widget.gameData.results[resultIndex];

    // 애니메이션 시작
    _animationController.reset();
    _animationController.forward();
  }

  void _showResultPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            
            // 결과 아이콘
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade500],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade300,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // 참가자 이름
            Text(
              '${widget.gameData.participants[_selectedParticipant!]}님의 결과',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            // 결과
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _result == '당첨' 
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (_result == '당첨' ? Colors.red : Colors.blue).shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _result!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // 버튼들
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), // 아래 여백 30px 추가
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // _resetGame()은 whenComplete에서 자동 호출됨
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '다시 하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 팝업 닫힌 후 새 사다리 생성
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _restartGame();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '새 사다리',
                        style: TextStyle(
                          fontSize: 16,
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
        ),
      ),
    ).whenComplete(() {
      // 팝업이 닫히면 자동으로 게임 상태 리셋하여 다른 참가자 선택 가능하게 함
      _resetGame();
    });
  }

  void _calculateAnimationPath(int startIndex) {
    final participantCount = widget.gameData.numberOfParticipants;
    final ladderHeight = widget.gameData.ladder.length;
    
    // 화면 크기 계산 (실제 CustomPainter와 동일한 계산)
    const topMargin = 100.0;
    const bottomMargin = 100.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final sideMargin = screenWidth < 400 ? 50.0 : 60.0;
    
    final screenHeight = MediaQuery.of(context).size.height - kToolbarHeight - 
                        MediaQuery.of(context).padding.top;
    
    final availableWidth = screenWidth - (sideMargin * 2);
    final availableHeight = (screenHeight - topMargin - bottomMargin) * 0.75; // 4분의 3으로 짧게
    
    // 컬럼 간격 계산 (LadderPainter와 동일한 방식 사용)
    final columnSpacing = participantCount > 1 
        ? availableWidth / (participantCount - 1)
        : availableWidth;
    
    // 사다리 높이 조정 (LadderPainter와 동일하게)
    final maxRows = (availableHeight / 10).floor(); // 최소 30픽셀 간격으로 더 납작하게
    final adjustedLadderHeight = math.min(ladderHeight, maxRows);
    final rowSpacing = availableHeight / adjustedLadderHeight;

    _animationPath.clear();
    
    int currentPosition = startIndex;
    
    // 시작점 (18px 왼쪽으로 이동)
    _animationPath.add(Offset(
      sideMargin + (currentPosition * columnSpacing) - 18,
      topMargin,
    ));

    // 사다리를 따라 경로 생성 (화면에 보이는 검은선까지만)
    for (int row = 0; row < adjustedLadderHeight; row++) {
      final currentY = topMargin + (row * rowSpacing);
      
      // 매 행마다 점을 추가하여 정확한 세로선 추적 (18px 왼쪽으로 이동)
      _animationPath.add(Offset(
        sideMargin + (currentPosition * columnSpacing) - 18,
        currentY,
      ));
      
      // 마지막 행이 아닌 경우에만 가로 이동 체크
      if (row < adjustedLadderHeight - 1) {
        // followLadderPath와 동일한 로직으로 가로 이동 체크
        // 왼쪽으로 갈 수 있는지 확인
        if (currentPosition > 0 && widget.gameData.ladder[row][currentPosition - 1]) {
          currentPosition--;
        // 가로 이동 후 점 추가 (18px 왼쪽으로 이동)
        _animationPath.add(Offset(
          sideMargin + (currentPosition * columnSpacing) - 18,
          currentY,
        ));
        }
        // 오른쪽으로 갈 수 있는지 확인
        else if (currentPosition < participantCount - 1 && widget.gameData.ladder[row][currentPosition]) {
          currentPosition++;
        // 가로 이동 후 점 추가 (18px 왼쪽으로 이동)
        _animationPath.add(Offset(
          sideMargin + (currentPosition * columnSpacing) - 18,
          currentY,
        ));
        }
      }
    }
    
    // 나머지 사다리 행들도 계산 (화면에 안 보이지만 경로 계산용)
    for (int row = adjustedLadderHeight; row < ladderHeight; row++) {
      // 왼쪽으로 갈 수 있는지 확인
      if (currentPosition > 0 && widget.gameData.ladder[row][currentPosition - 1]) {
        currentPosition--;
      }
      // 오른쪽으로 갈 수 있는지 확인
      else if (currentPosition < participantCount - 1 && widget.gameData.ladder[row][currentPosition]) {
        currentPosition++;
      }
    }
    
    // 최종 도착점 (결과 원 위에서 멈춤)
    final resultCircleTop = screenHeight - bottomMargin - 130; // 결과 원 위쪽 위치
    _animationPath.add(Offset(
      sideMargin + (currentPosition * columnSpacing) - 18, // 18px 왼쪽으로 이동
      resultCircleTop, // 결과 원 위에서 멈춤
    ));

  }

  void _resetGame() {
    setState(() {
      _isAnimating = false;
      _selectedParticipant = null;
      _result = null;
      _showResult = false;
      _animationPath.clear();
    });
    _animationController.reset();
  }

  void _restartGame() {
    // 새로운 사다리 생성
    widget.gameData.generateLadder();
    _resetGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          '사다리타기',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restartGame,
            tooltip: '새로운 사다리',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade100, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // 안내 메시지
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
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
              child: Text(
                _isAnimating 
                  ? '${widget.gameData.participants[_selectedParticipant!]}님이 사다리를 타고 있습니다...'
                  : _showResult
                    ? '다른 참가자를 선택하시려면 이름을 탭하세요!'
                    : '참가자 이름을 탭해서 사다리타기를 시작하세요!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 사다리 그리기 영역
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTapDown: (details) {
                      if (!_isAnimating) {
                        _handleTap(details.localPosition);
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: LadderPainter(
                            ladder: widget.gameData.ladder,
                            participants: widget.gameData.participants,
                            results: widget.gameData.results,
                            animationPath: _animationPath,
                            animationProgress: _animation.value,
                            selectedParticipant: _selectedParticipant,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position) {
    // 터치 위치에서 가장 가까운 참가자 찾기
    const topMargin = 100.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final sideMargin = screenWidth < 400 ? 50.0 : 60.0;
    
    final participantCount = widget.gameData.numberOfParticipants;
    final availableWidth = screenWidth - (sideMargin * 2);
    
    // 컬럼 간격 계산 (애니메이션 경로와 동일한 방식)
    final columnSpacing = participantCount > 1 
        ? availableWidth / (participantCount - 1)
        : availableWidth;

    // 참가자 이름 영역 터치 감지 (상단 영역)
    if (position.dy < topMargin) {
      for (int i = 0; i < participantCount; i++) {
        final participantX = sideMargin + (i * columnSpacing);
        final distance = (position.dx - participantX).abs();
        
        if (distance < 40) { // 터치 영역
          // 결과가 표시된 상태에서는 먼저 리셋하고 새 게임 시작
          if (_showResult) {
            _resetGame();
            // 짧은 딜레이 후 새 게임 시작
            Future.delayed(const Duration(milliseconds: 100), () {
              _startLadderGame(i);
            });
          } else {
            _startLadderGame(i);
          }
          break;
        }
      }
    }
  }
}
