import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'notification_service.dart';
import 'widget_service.dart';

class ProductService {
  static const String _productsKey = 'products';
  static ProductService? _instance;
  static ProductService get instance => _instance ??= ProductService._();
  
  final NotificationService _notificationService = NotificationService();
  final WidgetService _widgetService = WidgetService();
  
  ProductService._();

  // 모든 제품 가져오기
  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getStringList(_productsKey) ?? [];
    
    return productsJson
        .map((json) => Product.fromJson(jsonDecode(json)))
        .toList();
  }

  // 제품 저장
  Future<void> saveProduct(Product product) async {
    final products = await getProducts();
    final existingIndex = products.indexWhere((p) => p.id == product.id);
    
    if (existingIndex >= 0) {
      products[existingIndex] = product;
    } else {
      products.add(product);
    }
    
    await _saveProducts(products);
  }

  // 제품 삭제
  Future<void> deleteProduct(String productId) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == productId);
    await _saveProducts(products);
  }

  // 제품 업데이트
  Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    
    if (index >= 0) {
      products[index] = product.copyWith(updatedAt: DateTime.now());
      await _saveProducts(products);
    }
  }

  // 현재 카운트 업데이트
  Future<void> updateCurrentCount(String productId, int count) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == productId);
    
    if (index >= 0) {
      final updatedProduct = products[index].copyWith(
        currentCount: count,
        updatedAt: DateTime.now(),
      );
      products[index] = updatedProduct;
      await _saveProducts(products);
      
      // 푸시 알림이 활성화되어 있으면 잠금화면 위젯 업데이트
      if (updatedProduct.pushEnabled) {
        await _notificationService.showLockScreenWidget(updatedProduct);
        // 홈 위젯도 업데이트
        await _widgetService.updateWidget(updatedProduct);
      }
    }
  }

  // 최종 단수 업데이트
  Future<void> updateFinalCount(String productId, int finalCount) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == productId);
    
    if (index >= 0) {
      products[index] = products[index].copyWith(
        finalCount: finalCount,
        updatedAt: DateTime.now(),
      );
      await _saveProducts(products);
    }
  }

  // 푸시 알림 설정 토글 (한 번에 하나만 활성화)
  Future<void> togglePushEnabled(String productId) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == productId);
    
    if (index >= 0) {
      final currentProduct = products[index];
      final newPushEnabled = !currentProduct.pushEnabled;
      
      // 모든 제품의 pushEnabled를 false로 설정
      for (int i = 0; i < products.length; i++) {
        if (products[i].pushEnabled) {
          products[i] = products[i].copyWith(
            pushEnabled: false,
            updatedAt: DateTime.now(),
          );
          // 기존 활성화된 제품의 알림 취소
          await _notificationService.cancelNotification(products[i].id);
        }
      }
      
      // 선택한 제품만 활성화
      products[index] = currentProduct.copyWith(
        pushEnabled: newPushEnabled,
        updatedAt: DateTime.now(),
      );
      await _saveProducts(products);
      
      // 푸시 알림 활성화/비활성화에 따라 잠금화면 위젯 처리
      if (newPushEnabled) {
        await _notificationService.showLockScreenWidget(products[index]);
        // 홈 위젯도 업데이트
        await _widgetService.updateWidget(products[index]);
        print('✅ ${products[index].name} 위젯 활성화');
      } else {
        await _notificationService.cancelNotification(productId);
        // 홈 위젯 제거
        await _widgetService.removeWidget();
        print('✅ 위젯 비활성화');
      }
    }
  }

  // 제품들을 SharedPreferences에 저장
  Future<void> _saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = products
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    
    await prefs.setStringList(_productsKey, productsJson);
  }
}
