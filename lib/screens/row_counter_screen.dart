import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class RowCounterScreen extends StatefulWidget {
  const RowCounterScreen({super.key});

  @override
  State<RowCounterScreen> createState() => _RowCounterScreenState();
}

class _RowCounterScreenState extends State<RowCounterScreen> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final ProductService _productService = ProductService.instance;
  List<Product> _products = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProducts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('🔄 [RowCounterScreen] 앱이 포그라운드로 돌아옴 - 데이터 리프레시');
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    print('📋 [RowCounterScreen] _loadProducts 호출됨');
    final products = await _productService.getProducts();
    if (mounted) {
      setState(() {
        _products = products;
      });
      print('✅ [RowCounterScreen] 제품 목록 업데이트 완료: ${products.length}개');
    }
  }

  Future<void> _addProduct() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AddProductDialog(),
    );

    if (result != null && result.isNotEmpty) {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _productService.saveProduct(newProduct);
      _loadProducts();
    }
  }

  Future<void> _pickImage(Product product) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedProduct = product.copyWith(
        imagePath: pickedFile.path,
        updatedAt: DateTime.now(),
      );
      await _productService.saveProduct(updatedProduct);
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    return Scaffold(
      appBar: AppBar(
        title: const Text('단수 체크기'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: _products.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '아직 등록된 제품이 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '새 제품을 추가해보세요!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCard(product);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
          _loadProducts();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 제품 이미지
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: product.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(product.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : IconButton(
                        onPressed: () => _pickImage(product),
                        icon: const Icon(Icons.add_a_photo, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 16),
              // 제품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '현재: ${product.currentCount}회',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (product.finalCount != null)
                      Text(
                        '최종: ${product.finalCount}회',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              // 푸시 알림 토글
              Switch(
                value: product.pushEnabled,
                onChanged: (value) async {
                  await _productService.togglePushEnabled(product.id);
                  _loadProducts();
                },
                activeColor: const Color(0xFFFF6B35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 제품 추가'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: '제품명',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, _nameController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
          ),
          child: const Text('추가'),
        ),
      ],
    );
  }
}
