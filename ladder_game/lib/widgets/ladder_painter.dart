import 'package:flutter/material.dart';
import 'dart:math' as math;

class LadderPainter extends CustomPainter {
  final List<List<bool>> ladder;
  final List<String> participants;
  final List<String> results;
  final List<Offset> animationPath;
  final double animationProgress;
  final int? selectedParticipant;

  LadderPainter({
    required this.ladder,
    required this.participants,
    required this.results,
    this.animationPath = const [],
    this.animationProgress = 0.0,
    this.selectedParticipant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final participantCount = participants.length;
    final ladderHeight = ladder.length;
    
    // 여백 계산 (참가자명 박스가 잘리지 않도록 충분한 여백 확보)
    const topMargin = 100.0; // 참가자명을 위한 충분한 상단 여백
    const bottomMargin = 100.0; // 결과명을 위한 충분한 하단 여백
    final sideMargin = size.width < 400 ? 50.0 : 60.0; // 좌우 여백 증가
    
    final availableWidth = size.width - (sideMargin * 2);
    final availableHeight = (size.height - topMargin - bottomMargin); // 4분의 3으로 짧게
    
    // 컬럼 간격 계산 (정확한 정렬을 위해 간단한 계산 사용)
    final columnSpacing = participantCount > 1 
        ? availableWidth / (participantCount - 1)
        : availableWidth;
    
    // 사다리 높이를 모바일에 맞게 조정 (더 납작하게)
    final maxRows = (availableHeight / 10).floor(); // 최소 10픽셀 간격으로 더 납작하게
    final adjustedLadderHeight = math.min(ladderHeight, maxRows);
    final rowSpacing = availableHeight / adjustedLadderHeight;

    // 참가자 이름 그리기
    _drawParticipantNames(canvas, size, sideMargin, topMargin, columnSpacing);
    
    // 결과 항목 그리기
    _drawResults(canvas, size, sideMargin, size.height - bottomMargin, columnSpacing);

    // 세로줄 그리기
    _drawVerticalLines(canvas, participantCount, sideMargin, topMargin, 
                      availableHeight, columnSpacing, bottomMargin, size, paint);

    // 가로줄 그리기
    _drawHorizontalLines(canvas, sideMargin, topMargin, columnSpacing, 
                        rowSpacing, adjustedLadderHeight, paint);

    // 애니메이션 경로 그리기
    if (animationPath.isNotEmpty && animationProgress > 0) {
      _drawAnimationPath(canvas, paint);
    }
  }

  void _drawParticipantNames(Canvas canvas, Size size, double sideMargin, 
                           double topMargin, double columnSpacing) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < participants.length; i++) {
      final x = sideMargin + (i * columnSpacing);
      
      // 배경 원 그리기
      final circlePaint = Paint()
        ..color = (selectedParticipant == i) 
            ? Colors.blue.shade600 
            : Colors.white
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.blue.shade600
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(x, topMargin - 50), 28, circlePaint);
      canvas.drawCircle(Offset(x, topMargin - 50), 28, borderPaint);

      // 텍스트 그리기
      textPainter.text = TextSpan(
        text: participants[i],
        style: TextStyle(
          color: (selectedParticipant == i) ? Colors.white : Colors.blue.shade600,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      
      final textOffset = Offset(
        x - textPainter.width / 2,
        topMargin - 50 - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  void _drawResults(Canvas canvas, Size size, double sideMargin, 
                   double bottomY, double columnSpacing) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < results.length; i++) {
      final x = sideMargin + (i * columnSpacing);
      
      // 배경 원 그리기 (참가자와 동일한 스타일)
      final boxPaint = Paint()
        ..color = Colors.amber.shade100
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.amber.shade600
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      // 그림자 효과
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      final center = Offset(x, bottomY + 30);
      final radius = 30.0; // 참가자와 동일한 크기
      
      // 그림자 그리기
      canvas.drawCircle(center, radius, shadowPaint);
      
      // 배경 원 그리기
      canvas.drawCircle(center, radius, boxPaint);
      canvas.drawCircle(center, radius, borderPaint);

      // 텍스트 그리기 (원의 중앙에 배치)
      textPainter.text = TextSpan(
        text: results[i],
        style: TextStyle(
          color: Colors.amber.shade800,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      
      final textOffset = Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  void _drawVerticalLines(Canvas canvas, int participantCount, double sideMargin,
                         double topMargin, double availableHeight, 
                         double columnSpacing, double bottomMargin, Size size, Paint paint) {
    for (int i = 0; i < participantCount; i++) {
      final x = sideMargin + (i * columnSpacing);
      final startY = topMargin;
      final endY = size.height - bottomMargin + 10; // 결과 박스 상단에서 멈춤
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  void _drawHorizontalLines(Canvas canvas, double sideMargin, double topMargin,
                           double columnSpacing, double rowSpacing, 
                           int adjustedLadderHeight, Paint paint) {
    // 조정된 사다리 높이만큼만 그리기 (결과 박스 위까지만)
    final maxRows = adjustedLadderHeight;
    
    for (int row = 0; row < maxRows; row++) {
      for (int col = 0; col < ladder[row].length; col++) {
        if (ladder[row][col]) {
          final y = topMargin + (row * rowSpacing);
          final startX = sideMargin + (col * columnSpacing);
          final endX = sideMargin + ((col + 1) * columnSpacing);
          
          // 가로줄 그리기 (둥근 끝점)
          final linePaint = Paint()
            ..color = Colors.black87
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          
          canvas.drawLine(
            Offset(startX, y),
            Offset(endX, y),
            linePaint,
          );
        }
      }
    }
  }

  void _drawAnimationPath(Canvas canvas, Paint paint) {
    if (animationPath.length < 2) return;

    final pathPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final ballPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final ballBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 경로 그리기
    final path = Path();
    path.moveTo(animationPath[0].dx, animationPath[0].dy);
    
    final currentIndex = (animationProgress * (animationPath.length - 1)).floor();
    final progress = (animationProgress * (animationPath.length - 1)) - currentIndex;
    
    for (int i = 1; i <= currentIndex && i < animationPath.length; i++) {
      path.lineTo(animationPath[i].dx, animationPath[i].dy);
    }
    
    canvas.drawPath(path, pathPaint);

    // 현재 위치에 공 그리기
    if (currentIndex < animationPath.length - 1) {
      final currentPos = animationPath[currentIndex];
      final nextPos = animationPath[currentIndex + 1];
      
      final currentBallPos = Offset(
        currentPos.dx + (nextPos.dx - currentPos.dx) * progress,
        currentPos.dy + (nextPos.dy - currentPos.dy) * progress,
      );
      
      // 공의 그림자 효과
      canvas.drawCircle(currentBallPos + const Offset(2, 2), 8, 
          Paint()..color = Colors.black.withOpacity(0.3));
      
      // 공 그리기
      canvas.drawCircle(currentBallPos, 8, ballPaint);
      canvas.drawCircle(currentBallPos, 8, ballBorderPaint);
    } else if (animationPath.isNotEmpty) {
      final finalPos = animationPath.last;
      // 공의 그림자 효과
      canvas.drawCircle(finalPos + const Offset(2, 2), 8, 
          Paint()..color = Colors.black.withOpacity(0.3));
      
      // 공 그리기
      canvas.drawCircle(finalPos, 8, ballPaint);
      canvas.drawCircle(finalPos, 8, ballBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
