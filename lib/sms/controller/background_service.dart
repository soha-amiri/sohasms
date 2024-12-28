import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';

import 'package:sohasms/sms/controller/sms_controller.dart';

class BackgroundServiceHelper {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'soha_sms_service',
        initialNotificationTitle: 'Soha SMS Service',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Listen for SMS
    var sms_controller = Get.find<SMSController>();
    sms_controller.listenIncomingSMS();
    // receiver?.listen((SmsMessage message) async {
    //   final isActive = box.read('isActive') ?? false;
    //   final forwardNumber = box.read('forwardNumber') ?? '';
    //   final selectedSim = box.read('selectedSim') ?? 1;
    //   final forwardAll = box.read('forwardAll') ?? true;
    //   final selectedContacts = box.read('selectedContacts') ?? [];

    //   if (isActive &&
    //       (forwardAll ||
    //           selectedContacts.contains(message.sender?.fixPhoneNumber()))) {
    //     String forwardMessageBody =
    //         'هدایت شده از\n"${message.sender?.fixPhoneNumber()}" : \n${message.body}';

    //     // Forward the message using your existing BackgroundSms plugin
    //     // Add your message forwarding logic here
    //   }
    // });
  }
}
