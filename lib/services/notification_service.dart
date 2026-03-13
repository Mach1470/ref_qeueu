import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ref_qeueu/services/database_service.dart';

/// Service for handling push notifications using Firebase Cloud Messaging
class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // INITIALIZATION
  // ---------------------------------------------------------------------------

  /// Initialize the notification service
  /// Call this in main.dart after Firebase.initializeApp()
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permission (iOS and web)
    await _requestPermission();

    // Initialize local notifications for foreground display
    await _initializeLocalNotifications();

    // Set up message handlers
    _setupMessageHandlers();

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'Notification permission status: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications for foreground messages
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'refugee_queue_channel',
      'Queue Notifications',
      description: 'Notifications for queue updates and alerts',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Set up FCM message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated app message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // ---------------------------------------------------------------------------
  // TOKEN MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Get the FCM token and save it for the user
  Future<String?> getAndSaveToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await DatabaseService.instance.saveFcmToken(userId, token);
        debugPrint('FCM token saved for user: $userId');
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Listen for token refresh and update stored token
  void listenForTokenRefresh(String userId) {
    _messaging.onTokenRefresh.listen((newToken) async {
      await DatabaseService.instance.saveFcmToken(userId, newToken);
      debugPrint('FCM token refreshed for user: $userId');
    });
  }

  /// Remove the FCM token (on logout)
  Future<void> removeToken(String userId) async {
    try {
      await DatabaseService.instance.removeFcmToken(userId);
      await _messaging.deleteToken();
      debugPrint('FCM token removed for user: $userId');
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // MESSAGE HANDLERS
  // ---------------------------------------------------------------------------

  /// Handle messages received while app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      // Show local notification
      _showLocalNotification(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when user taps a notification (app was in background/terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    // Handle navigation based on message data
    _handleNavigation(message.data);
  }

  /// Handle notification tap from local notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Parse payload and navigate
  }

  /// Handle navigation based on notification data
  void _handleNavigation(Map<String, dynamic> data) {
    // TODO: Implement navigation using a global navigator key
    // Example:
    // if (data['type'] == 'queue_update') {
    //   navigatorKey.currentState?.pushNamed('/queue');
    // }
    debugPrint('Navigation data: $data');
  }

  // ---------------------------------------------------------------------------
  // LOCAL NOTIFICATIONS
  // ---------------------------------------------------------------------------

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'refugee_queue_channel',
      'Queue Notifications',
      channelDescription: 'Notifications for queue updates and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ---------------------------------------------------------------------------
  // PUBLIC NOTIFICATION METHODS
  // ---------------------------------------------------------------------------

  /// Show a queue position update notification
  Future<void> showQueueUpdateNotification({
    required int position,
    required String facilityName,
  }) async {
    await _showLocalNotification(
      title: 'Queue Update',
      body: 'You are now #$position in line at $facilityName',
      payload: 'queue_update',
    );
  }

  /// Show a "your turn" notification
  Future<void> showYourTurnNotification({
    required String department,
    String? room,
  }) async {
    await _showLocalNotification(
      title: "It's Your Turn!",
      body: 'Please proceed to ${room ?? department}',
      payload: 'your_turn',
    );
  }

  /// Show a prescription ready notification
  Future<void> showPrescriptionReadyNotification({
    required String pharmacyName,
  }) async {
    await _showLocalNotification(
      title: 'Prescription Ready',
      body: 'Your medicines are ready for collection at $pharmacyName',
      payload: 'prescription_ready',
    );
  }

  /// Show a lab results ready notification
  Future<void> showLabResultsNotification({
    required String testType,
  }) async {
    await _showLocalNotification(
      title: 'Lab Results Available',
      body: 'Your $testType results are ready',
      payload: 'lab_results',
    );
  }

  /// Show an ambulance status notification
  Future<void> showAmbulanceStatusNotification({
    required String status,
    int? etaMinutes,
  }) async {
    String body;
    switch (status) {
      case 'dispatched':
        body = 'An ambulance has been dispatched to your location';
        break;
      case 'en_route':
        body = etaMinutes != null
            ? 'Ambulance is on the way. ETA: $etaMinutes minutes'
            : 'Ambulance is on the way';
        break;
      case 'arrived':
        body = 'The ambulance has arrived at your location';
        break;
      default:
        body = 'Ambulance status: $status';
    }

    await _showLocalNotification(
      title: 'Ambulance Update',
      body: body,
      payload: 'ambulance_$status',
    );
  }

  // ---------------------------------------------------------------------------
  // TOPIC SUBSCRIPTIONS
  // ---------------------------------------------------------------------------

  /// Subscribe to facility-specific notifications
  Future<void> subscribeToFacility(String facilityId) async {
    await _messaging.subscribeToTopic('facility_$facilityId');
    debugPrint('Subscribed to facility: $facilityId');
  }

  /// Unsubscribe from facility notifications
  Future<void> unsubscribeFromFacility(String facilityId) async {
    await _messaging.unsubscribeFromTopic('facility_$facilityId');
    debugPrint('Unsubscribed from facility: $facilityId');
  }

  /// Subscribe to emergency alerts
  Future<void> subscribeToEmergencyAlerts() async {
    await _messaging.subscribeToTopic('emergency_alerts');
    debugPrint('Subscribed to emergency alerts');
  }

  /// Subscribe to general announcements
  Future<void> subscribeToAnnouncements() async {
    await _messaging.subscribeToTopic('announcements');
    debugPrint('Subscribed to announcements');
  }
}

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Handle background message - minimal processing here
}
