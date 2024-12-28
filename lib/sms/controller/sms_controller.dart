import 'dart:async';
import 'package:background_sms/background_sms.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sohasms/notification/notif_config.dart';

import '../../main.dart';

class SMSController extends GetxController {
  final box = GetStorage('SMSBox');
  final _forwardNumber = ''.obs;
  final SmsQuery query = SmsQuery();
  Stream<SmsMessage>? receiver = SmsReceiver().onSmsReceived;
  final _isActive = false.obs;
  final _contacts = {}.obs;

  final RxList<SmsThread> threads = List<SmsThread>.empty(growable: true).obs;
  final _selectedSim = 1.obs;
  final _selectedContacts = List.empty(growable: true).obs;
  final _forwardAll = false.obs;

  bool get isActive => _isActive.value;
  String get forwardNumber => _forwardNumber.value;
  int get selectedSim => _selectedSim.value;
  List get selectedContacts => _selectedContacts;
  bool get forwardAll => _forwardAll.value;
  Map get contactNumbers => _contacts;

  @override
  void onInit() {
    super.onInit();
    _fetchData();
    _getThreads();
    listenIncomingSMS();
  }

  Future<void> activateListening(bool active) async {
    _isActive.value = active;
    String body = active ? 'هدایت پیام ها فعال شد' : 'هدایت پیام ها غیرفعال شد';
    NotificationConfig.showNotification(0,
        title: 'Soha SMS', body: body, payload: body, ongoing: active);
  }

  Future<void> _getThreads() async {
    try {
      threads.value = await query.getAllThreads;
    } catch (e) {
      print('Error fetching threads: $e');
    }
  }

  void _fetchData() {
    _forwardNumber.value = box.read('forwardNumber') ?? '';
    _selectedSim.value = box.read('selectedSim') ?? 1;
    _selectedContacts.value = box.read('selectedContacts') ?? [];
    _forwardAll.value = box.read('forwardAll') ?? true;
  }

  Future<void> changeForwardAll(bool value) async {
    _forwardAll.value = value;
    await box.write('forwardAll', value);
  }

  Future<void> changeForwardNumber(String number) async {
    _forwardNumber.value = number;
    await box.write('forwardNumber', number);
  }

  Future<void> changeSelectedSim(int sim) async {
    _selectedSim.value = sim;
    await box.write('selectedSim', sim);
    Get.back();
  }

  Future<void> changeSelectedContacts(List<String> contacts) async {
    _selectedContacts.value = contacts.fixPhoneNumbers();
    await box.write('selectedContacts', selectedContacts);
  }

  Future<void> forwardMessage(
      {required SmsMessage message, String? contact}) async {
    String forwardMessageBody =
        'هدایت شده از\n"${contact!.isEmpty ? message.sender?.fixPhoneNumber() : contact}" : \n${message.body}';
    var result = await BackgroundSms.sendMessage(
        phoneNumber: _forwardNumber.value,
        simSlot: _selectedSim.value,
        message: forwardMessageBody.toPersianDigit());
    if (result == SmsStatus.sent) {
      print("Sent");
      Fluttertoast.showToast(msg: 'پیام فوروارد شد');
      _getThreads();
    } else {
      print("Failed");
      Fluttertoast.showToast(msg: 'پیام فوروارد نشد');
    }
  }

  Future<void> listenIncomingSMS() async {
    _contacts.value = await getContactNumbersIsolate();

    receiver?.listen((SmsMessage message) async {
      print('received');
      if (isActive &&
          (forwardAll ||
              selectedContacts.contains(message.sender?.fixPhoneNumber()))) {
        String contact = contactNumbers.entries
            .firstWhere(
              (element) => element.value == message.sender?.fixPhoneNumber(),
              orElse: () => const MapEntry('', ''),
            )
            .key;
        await forwardMessage(message: message, contact: contact);
      }
    });
  }
}

extension PhoneNumberExtension on List<String> {
  List<String> fixPhoneNumbers() {
    return map((element) {
      if (element.numericOnly().startsWith('98')) {
        return element.numericOnly().replaceRange(0, 2, '0');
      } else {
        return element.numericOnly();
      }
    }).toList();
  }
}

extension StringExtension on String {
  String fixPhoneNumber() {
    if (numericOnly().startsWith('98')) {
      return numericOnly().replaceRange(0, 2, '0');
    } else {
      return numericOnly();
    }
  }
}
