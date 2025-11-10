import 'dart:math';

class LadderGameData {
  List<String> participants;
  List<String> results;
  int numberOfParticipants;
  int numberOfResults;
  List<List<bool>> ladder;

  LadderGameData({
    required this.numberOfParticipants,
    required this.numberOfResults,
  })  : participants = _generateDefaultParticipants(numberOfParticipants),
        results = _generateDefaultResults(numberOfResults),
        ladder = [];

  // 기본 참가자 이름 생성 (랜덤 4자 한글 이름)
  static List<String> _generateDefaultParticipants(int count) {
    final random = Random();
    final lastNames = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임'];
    final firstNames = ['민수', '영희', '철수', '영수', '현진', '지훈', '수빈', '예진', '도현', '서연',
                       '준호', '하은', '민준', '서현', '지우', '예은', '태현', '유진', '승현', '나영'];
    
    List<String> names = [];
    for (int i = 0; i < count; i++) {
      final lastName = lastNames[random.nextInt(lastNames.length)];
      final firstName = firstNames[random.nextInt(firstNames.length)];
      names.add(lastName + firstName);
    }
    return names;
  }

  // 기본 결과 이름 생성 (첫번째는 당첨, 나머지는 꽝)
  static List<String> _generateDefaultResults(int count) {
    List<String> results = [];
    for (int i = 0; i < count; i++) {
      if (i == 0) {
        results.add('당첨');
      } else {
        results.add('꽝');
      }
    }
    return results;
  }

  // 참가자 이름 설정
  void setParticipant(int index, String name) {
    if (index >= 0 && index < participants.length) {
      participants[index] = name;
    }
  }

  // 결과 항목 설정
  void setResult(int index, String result) {
    if (index >= 0 && index < results.length) {
      results[index] = result;
    }
  }

  // 모든 참가자 이름이 입력되었는지 확인
  bool get areParticipantsComplete {
    return participants.every((name) => name.trim().isNotEmpty);
  }

  // 모든 결과 항목이 입력되었는지 확인
  bool get areResultsComplete {
    return results.every((result) => result.trim().isNotEmpty);
  }

  // 사다리 생성
  void generateLadder() {
    final random = Random();
    // 모바일에 적합한 사다리 높이 (참가자 수에 따라 조정)
    final ladderHeight = numberOfParticipants * 6 + 10; // 적절한 높이 설정
    
    // 마지막 영역 계산 (전체 높이의 약 15% 또는 최소 3행)
    final bottomExcludeRows = ((ladderHeight * 0.15).round() > 3) 
        ? (ladderHeight * 0.15).round() 
        : 3;
    
    ladder = List.generate(
      ladderHeight,
      (_) => List.filled(numberOfParticipants - 1, false),
    );

    // 가로줄을 랜덤하게 생성 (5-8개 보장)
    int crossingsCreated = 0;
    final minCrossings = 5; // 최소 5개
    final maxCrossings = 8; // 최대 8개
    final targetCrossings = random.nextInt(maxCrossings - minCrossings + 1) + minCrossings; // 5-8개 랜덤
    
    // 첫 번째 패스: 기본 가로줄 생성 (더 많이 생성, 마지막 영역 제외)
    for (int i = 2; i < ladder.length - bottomExcludeRows; i += 2) { // 마지막 영역 제외
      for (int j = 0; j < numberOfParticipants - 1; j++) {
        // 80% 확률로 가로줄 생성 (확률 대폭 증가)
        if (random.nextDouble() < 0.8) {
          // 인접한 가로줄이 없는지 확인
          bool canPlace = true;
          
          // 같은 행에서 왼쪽 가로줄과 겹치는지 확인
          if (j > 0 && ladder[i][j - 1]) {
            canPlace = false;
          }
          
          // 같은 행에서 오른쪽 가로줄과 겹치는지 확인
          if (j < numberOfParticipants - 2 && ladder[i][j + 1]) {
            canPlace = false;
          }
          
          if (canPlace) {
            ladder[i][j] = true;
            crossingsCreated++;
          }
        }
      }
    }
    
    // 두 번째 패스: 목표 가로줄 개수까지 생성 (마지막 영역 제외)
    int attempts = 0;
    while (crossingsCreated < targetCrossings && attempts < 300) { // 목표 개수까지 생성
      final row = random.nextInt(ladder.length - bottomExcludeRows - 4) + 2; // 마지막 영역 제외
      final col = random.nextInt(numberOfParticipants - 1);
      
      if (!ladder[row][col]) {
        // 완화된 인접성 검사
        bool canPlace = true;
        
        // 같은 행에서 인접한 가로줄 확인
        if (col > 0 && ladder[row][col - 1]) canPlace = false;
        if (col < numberOfParticipants - 2 && ladder[row][col + 1]) canPlace = false;
        
        // 위아래 행 검사 완화 (1행 건너뛰어도 OK)
        if (row > 0 && ladder[row - 1][col]) canPlace = false;
        if (row < ladder.length - 1 && ladder[row + 1][col]) canPlace = false;
        
        if (canPlace) {
          ladder[row][col] = true;
          crossingsCreated++;
        }
      }
      attempts++;
    }
    
    // 세 번째 패스: 절대 최소값 강제 생성 (5개 절대 보장)
    if (crossingsCreated < minCrossings) {
      for (int i = 0; i < minCrossings - crossingsCreated; i++) {
        int attempts2 = 0;
        while (attempts2 < 50) {
          final row = random.nextInt(ladder.length - bottomExcludeRows - 6) + 3; // 마지막 영역 제외
          final col = random.nextInt(numberOfParticipants - 1);
          
          if (!ladder[row][col]) {
            // 최소한의 검사만 수행
            bool canPlace = true;
            if (col > 0 && ladder[row][col - 1]) canPlace = false;
            if (col < numberOfParticipants - 2 && ladder[row][col + 1]) canPlace = false;
            
            if (canPlace) {
              ladder[row][col] = true;
              crossingsCreated++;
              break;
            }
          }
          attempts2++;
        }
      }
    }
    
    // 네 번째 패스: 강제 생성 (모든 규칙 무시하고 최소 5개 절대 보장)
    if (crossingsCreated < minCrossings) {
      final remainingNeeded = minCrossings - crossingsCreated;
      int forcedAttempts = 0;
      
      while (crossingsCreated < minCrossings && forcedAttempts < 100) {
        final row = random.nextInt(ladder.length - bottomExcludeRows - 2) + 1;
        final col = random.nextInt(numberOfParticipants - 1);
        
        if (!ladder[row][col]) {
          // 기본적인 인접성만 확인 (같은 행에서만)
          bool canPlace = true;
          if (col > 0 && ladder[row][col - 1]) canPlace = false;
          if (col < numberOfParticipants - 2 && ladder[row][col + 1]) canPlace = false;
          
          if (canPlace) {
            ladder[row][col] = true;
            crossingsCreated++;
          }
        }
        forcedAttempts++;
      }
    }
    
    // 최종 확인: 정말로 최소 5개가 안 되면 강제 배치
    if (crossingsCreated < minCrossings) {
      final positions = <List<int>>[];
      for (int row = 2; row < ladder.length - bottomExcludeRows - 2; row += 3) {
        for (int col = 0; col < numberOfParticipants - 1; col++) {
          if (!ladder[row][col]) {
            positions.add([row, col]);
          }
        }
      }
      
      // 랜덤하게 섞어서 필요한 만큼 강제 배치
      positions.shuffle(random);
      final needed = minCrossings - crossingsCreated;
      for (int i = 0; i < needed && i < positions.length; i++) {
        final pos = positions[i];
        ladder[pos[0]][pos[1]] = true;
        crossingsCreated++;
      }
    }
  }

  // 사다리 타기 결과 계산
  int followLadderPath(int startIndex) {
    int currentPosition = startIndex;
    
    for (int row = 0; row < ladder.length; row++) {
      // 왼쪽으로 갈 수 있는지 확인
      if (currentPosition > 0 && ladder[row][currentPosition - 1]) {
        currentPosition--;
      }
      // 오른쪽으로 갈 수 있는지 확인
      else if (currentPosition < numberOfParticipants - 1 && ladder[row][currentPosition]) {
        currentPosition++;
      }
    }
    
    return currentPosition;
  }
}
