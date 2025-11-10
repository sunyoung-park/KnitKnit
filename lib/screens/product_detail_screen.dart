import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with WidgetsBindingObserver {
  final ProductService _productService = ProductService.instance;
  late Product _product;
  final TextEditingController _finalCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _product = widget.product;
    if (_product.finalCount != null) {
      _finalCountController.text = _product.finalCount.toString();
    }
    print('📱 [ProductDetailScreen] initState - 초기 데이터 로드');
    _loadLatestProduct();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _finalCountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('🔄 [ProductDetailScreen] 앱이 포그라운드로 돌아옴 - 데이터 리프레시');
      _loadLatestProduct();
    }
  }

  // 최신 제품 데이터 로드
  Future<void> _loadLatestProduct() async {
    print('📋 [ProductDetailScreen] _loadLatestProduct 호출됨');
    final products = await _productService.getProducts();
    try {
      final latestProduct = products.firstWhere((p) => p.id == _product.id);
      if (mounted) {
        setState(() {
          _product = latestProduct;
          if (_product.finalCount != null) {
            _finalCountController.text = _product.finalCount.toString();
          }
        });
        print('✅ [ProductDetailScreen] 제품 데이터 업데이트 완료: ${_product.name} - 현재: ${_product.currentCount}번');
      }
    } catch (e) {
      print('❌ [ProductDetailScreen] 제품 로드 에러: $e');
    }
  }

  Future<void> _updateCurrentCount(int newCount) async {
    await _productService.updateCurrentCount(_product.id, newCount);
    setState(() {
      _product = _product.copyWith(currentCount: newCount);
    });
  }

  Future<void> _updateFinalCount() async {
    final finalCount = int.tryParse(_finalCountController.text);
    if (finalCount != null && finalCount > 0) {
      await _productService.updateFinalCount(_product.id, finalCount);
      setState(() {
        _product = _product.copyWith(finalCount: finalCount);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최종 횟수가 설정되었습니다')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedProduct = _product.copyWith(
        imagePath: pickedFile.path,
        updatedAt: DateTime.now(),
      );
      await _productService.saveProduct(updatedProduct);
      setState(() {
        _product = updatedProduct;
      });
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('제품 삭제'),
        content: const Text('이 제품을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _productService.deleteProduct(_product.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          // 뒤로가기 시 최신 데이터를 로드하고 횟수 체크기 화면으로 이동
          await _loadLatestProduct();
          if (mounted) {
            // 현재 화면을 닫고 횟수 체크기 화면까지 모두 pop
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_product.name),
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // 뒤로가기 버튼 누를 때 최신 데이터 로드 후 횟수 체크기 화면으로
              await _loadLatestProduct();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          actions: [
          IconButton(
            onPressed: _deleteProduct,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 제품 이미지
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _product.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_product.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('사진 추가'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // 현재 체크 수
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF6B35)),
              ),
              child: Column(
                children: [
                  const Text(
                    '현재 체크 수',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_product.currentCount}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateCurrentCount(_product.currentCount - 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.remove, size: 24),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateCurrentCount(0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateCurrentCount(_product.currentCount + 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.add, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 최종 횟수 설정
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '최종 횟수 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_product.finalCount != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '목표: ${_product.finalCount}번',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _finalCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '최종 횟수',
                            border: OutlineInputBorder(),
                            suffixText: '번',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _updateFinalCount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('설정'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 푸시 알림 설정
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '위젯 표시',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '홈 화면 & 잠금화면 위젯',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _product.pushEnabled,
                        onChanged: (value) async {
                          await _productService.togglePushEnabled(_product.id);
                          // 다시 로드하여 최신 상태 반영
                          final products = await _productService.getProducts();
                          final updatedProduct = products.firstWhere((p) => p.id == _product.id);
                          setState(() {
                            _product = updatedProduct;
                          });
                        },
                        activeColor: const Color(0xFFFF6B35),
                      ),
                    ],
                  ),
                  if (_product.pushEnabled) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFFFF6B35),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '이 제품만 위젯에 표시됩니다',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
