class Product {
  final String id;
  final String name;
  final String? imagePath;
  int currentCount;
  int? finalCount;
  bool pushEnabled;
  final DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.imagePath,
    this.currentCount = 0,
    this.finalCount,
    this.pushEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'currentCount': currentCount,
      'finalCount': finalCount,
      'pushEnabled': pushEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // JSON에서 객체 생성
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      currentCount: json['currentCount'] ?? 0,
      finalCount: json['finalCount'],
      pushEnabled: json['pushEnabled'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // 복사본 생성 (수정용)
  Product copyWith({
    String? id,
    String? name,
    String? imagePath,
    int? currentCount,
    int? finalCount,
    bool? pushEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      currentCount: currentCount ?? this.currentCount,
      finalCount: finalCount ?? this.finalCount,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
