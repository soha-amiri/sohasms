import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sohasms/notification/notif_config.dart';
import 'package:sohasms/sms/controller/background_service.dart';
import 'package:sohasms/sms/controller/sms_controller.dart';
import 'package:sohasms/sms/view/pages/inbox_page.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

Future<Map<String, dynamic>> getContactNumbersIsolate() async {
  var rootToken = RootIsolateToken.instance!;
  print('This function is running on: ${Isolate.current.debugName}');
  return Isolate.run(() => _getContactNumbersIsolate(rootToken));
}

@pragma('vm:entry-point')
Future<Map<String, String>> _getContactNumbersIsolate(
    RootIsolateToken rootToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  print('This function is running on: ${Isolate.current.debugName}');
  final contacts = await fc.FlutterContacts.getContacts(
    withProperties: true,
  );

  final filteredContacts =
      contacts.where((element) => element.phones.isNotEmpty).toList();
  final contactNumbers = {
    for (var contact in filteredContacts)
      contact.displayName: contact.phones.first.number.fixPhoneNumber()
  };
  return contactNumbers;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationConfig.init();
  await GetStorage.init('SMSBox');
  await Permission.contacts.request();
  await Permission.sms.request();
  await Permission.notification.request();
  // await BackgroundServiceHelper.initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Soha SMS',
      locale: const Locale('fa', 'IR'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'yekan'),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'yekan'),
      themeMode: ThemeMode.dark,
      home: InboxPage(),
    );
  }
}
