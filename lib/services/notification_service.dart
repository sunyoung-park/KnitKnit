import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/product.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // 알림 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
  }

  // 알림 권한 요청
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // 알림 응답 처리 (알림 탭 시 앱 열기)
  void _onNotificationResponse(NotificationResponse response) {
    print('📱 알림 탭됨: ${response.payload}');
    // 알림을 탭하면 앱이 열립니다
  }

  // 잠금화면 위젯 알림 표시
  Future<void> showLockScreenWidget(Product product) async {
    if (!_initialized) await initialize();
    if (!product.pushEnabled) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final currentCount = product.currentCount;
    final finalCount = product.finalCount ?? 0;

    // Android 알림 (실시간 횟수 표시)
    final androidDetails = AndroidNotificationDetails(
      'row_counter_widget_v4',
      '횟수 체크',
      channelDescription: '현재 진행 중인 횟수를 표시합니다',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showProgress: finalCount > 0,
      maxProgress: finalCount > 0 ? finalCount : 100,
      progress: currentCount,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      showWhen: false,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String title = '${product.name}';
    String body = finalCount > 0 
        ? '$currentCount / $finalCount번'
        : '$currentCount번';

    await _notifications.show(
      product.id.hashCode,
      title,
      body,
      details,
      payload: product.id,
    );
  }

  // 특정 제품의 알림 취소
  Future<void> cancelNotification(String productId) async {
    await _notifications.cancel(productId.hashCode);
  }

  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
