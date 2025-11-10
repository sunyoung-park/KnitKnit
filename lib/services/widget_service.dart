import 'package:home_widget/home_widget.dart';
import '../models/product.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  // 위젯 업데이트
  Future<void> updateWidget(Product product) async {
    try {
      // 위젯에 데이터 저장
      await HomeWidget.saveWidgetData<String>('widget_product_id', product.id);
      await HomeWidget.saveWidgetData<String>('widget_product_name', product.name);
      await HomeWidget.saveWidgetData<int>('widget_current_count', product.currentCount);
      
      // 위젯 업데이트
      await HomeWidget.updateWidget(
        name: 'CounterWidgetProvider',
        androidName: 'CounterWidgetProvider',
      );
      
      print('✅ 위젯 업데이트 완료: ${product.name} - ${product.currentCount}번');
    } catch (e) {
      print('❌ 위젯 업데이트 실패: $e');
    }
  }

  // 위젯에서 액션 받기
  Future<Map<String, String>?> getWidgetAction() async {
    try {
      final action = await HomeWidget.getWidgetData<String>('widget_action');
      final productId = await HomeWidget.getWidgetData<String>('widget_action_product_id');
      
      // 액션이 있을 때만 로그 출력
      if (action != null && productId != null && action.isNotEmpty && productId.isNotEmpty) {
        print('✅ 위젯 액션 발견: $action, $productId');
        // 액션 초기화
        await HomeWidget.saveWidgetData<String>('widget_action', '');
        await HomeWidget.saveWidgetData<String>('widget_action_product_id', '');
        
        return {'action': action, 'productId': productId};
      }
      
      return null;
    } catch (e) {
      print('❌ 위젯 액션 가져오기 실패: $e');
      return null;
    }
  }

  // 위젯 제거
  Future<void> removeWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>('widget_product_id', '');
      await HomeWidget.saveWidgetData<String>('widget_product_name', '');
      await HomeWidget.saveWidgetData<int>('widget_current_count', 0);
      
      await HomeWidget.updateWidget(
        name: 'CounterWidgetProvider',
        androidName: 'CounterWidgetProvider',
      );
      
      print('✅ 위젯 제거 완료');
    } catch (e) {
      print('❌ 위젯 제거 실패: $e');
    }
  }
}

