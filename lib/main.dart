import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'screens/gauge_calculator_screen.dart';
import 'screens/row_counter_screen.dart';
import 'screens/product_detail_screen.dart';
import 'services/notification_service.dart';
import 'services/product_service.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 앱 시작');
  
  // 알림 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const KnitKnitApp());
}

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class KnitKnitApp extends StatefulWidget {
  const KnitKnitApp({super.key});

  @override
  State<KnitKnitApp> createState() => _KnitKnitAppState();
}

class _KnitKnitAppState extends State<KnitKnitApp> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.knitknit/widget');
  Timer? _widgetCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialIntent();
    _listenToIntents();
    _startWidgetActionPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _widgetCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('🔄 앱이 포그라운드로 돌아옴 - 위젯 액션 확인');
      _checkWidgetAction();
    }
  }

  // 위젯 액션 폴링 시작 (1초마다)
  void _startWidgetActionPolling() {
    _widgetCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _checkWidgetAction();
    });
    print('✅ 위젯 액션 폴링 시작 (1초마다)');
  }

  // 위젯 액션 확인
  Future<void> _checkWidgetAction() async {
    try {
      final action = await HomeWidget.getWidgetData<String>('widget_action');
      final productId = await HomeWidget.getWidgetData<String>('widget_action_product_id');

      if (action != null && productId != null && action.isNotEmpty && productId.isNotEmpty) {
        print('========================================');
        print('🎯 위젯 액션 감지: action=$action, productId=$productId');
        print('========================================');

        final productService = ProductService.instance;
        final products = await productService.getProducts();

        try {
          final product = products.firstWhere((p) => p.id == productId);
          int newCount = product.currentCount;

          switch (action) {
            case 'increase':
              newCount = product.currentCount + 1;
              print('➕ Flutter 증가: ${product.currentCount} → $newCount');
              break;
            case 'decrease':
              if (product.currentCount > 0) {
                newCount = product.currentCount - 1;
              }
              print('➖ Flutter 감소: ${product.currentCount} → $newCount');
              break;
            case 'reset':
              newCount = 0;
              print('🔄 Flutter 리셋: ${product.currentCount} → $newCount');
              break;
          }

          await productService.updateCurrentCount(productId, newCount);
          print('✅ Flutter 데이터 업데이트 완료: $newCount');

          // 액션 초기화
          await HomeWidget.saveWidgetData<String>('widget_action', '');
          await HomeWidget.saveWidgetData<String>('widget_action_product_id', '');
        } catch (e) {
          print('❌ 제품을 찾을 수 없음: $e');
        }
      }
    } catch (e) {
      print('❌ 위젯 액션 확인 에러: $e');
    }
  }

  // 앱 시작 시 Intent 확인
  Future<void> _checkInitialIntent() async {
    try {
      final String? action = await platform.invokeMethod('getInitialIntent');
      if (action == 'ACTION_OPEN_PRODUCT') {
        final String? productId = await platform.invokeMethod('getProductId');
        if (productId != null) {
          print('🎯 초기 Intent: productId=$productId');
          _openProductDetail(productId);
        }
      }
    } catch (e) {
      print('❌ 초기 Intent 확인 에러: $e');
    }
  }

  // Intent 리스닝
  void _listenToIntents() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onNewIntent') {
        final String? action = call.arguments['action'];
        final String? productId = call.arguments['product_id'];
        
        print('🎯 새 Intent: action=$action, productId=$productId');
        
        if (action == 'ACTION_OPEN_PRODUCT' && productId != null) {
          _openProductDetail(productId);
        }
      }
    });
  }

  // 제품 상세 화면 열기
  Future<void> _openProductDetail(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final productService = ProductService.instance;
    final products = await productService.getProducts();
    
    try {
      final product = products.firstWhere((p) => p.id == productId);
      print('✅ 제품 찾음: ${product.name}');
      
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      }
    } catch (e) {
      print('❌ 제품을 찾을 수 없음: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '뜨개뜨개',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'NotoSansKR',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GaugeCalculatorScreen(),
    const RowCounterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: '게이지 계산기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: '횟수 체크기',
          ),
        ],
      ),
    );
  }
}
