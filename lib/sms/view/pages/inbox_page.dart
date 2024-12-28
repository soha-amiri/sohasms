import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:sohasms/notification/notif_config.dart';
import 'package:sohasms/sms/controller/sms_controller.dart';
import 'package:sohasms/sms/view/pages/messages_pages.dart';
import 'package:sohasms/sms/view/pages/settings_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final smsController = Get.put(SMSController());
  final SmsQuery query = SmsQuery();
  List<SmsThread> threads = [];
  SmsReceiver? _smsReceiver;

  @override
  void initState() {
    super.initState();
    _forwardController =
        TextEditingController(text: smsController.forwardNumber);
    _configureSelectNotificationSubject();
  }

  SmsSender sender = SmsSender();
  late TextEditingController _forwardController;

  void _configureSelectNotificationSubject() {
    NotificationConfig.selectNotificationStream.stream
        .listen((NotificationResponse? response) async {
      if (response?.actionId == 'disable') {
        await NotificationConfig.cancelNotification(0);
        smsController.activateListening(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    NotificationConfig.selectNotificationStream.close();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text("پیام ها"),
          actions: [
            Switch(
              value: smsController.isActive,
              onChanged: (active) async {
                if (smsController.forwardNumber.isEmpty) {
                  await Get.defaultDialog(
                    title: 'ورود شماره',
                    barrierDismissible: false,
                    content: ForwardNumberChoose(),
                  );
                }
                smsController.activateListening(active);
              },
            ),
            IconButton(
              onPressed: () {
                Get.to(() => SettingsPage());
              },
              icon: const Icon(Icons.settings),
            ),
          ],
          backgroundColor: Get.theme.secondaryHeaderColor,
          elevation: 3,
        ),
        bottomNavigationBar: Container(
          alignment: Alignment.center,
          height: 50,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: smsController.isActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            smsController.isActive ? 'فعال' : 'غیرفعال',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView.builder(
          itemCount: smsController.threads.length,
          itemBuilder: (BuildContext context, int index) {
            var threads = smsController.threads[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  minVerticalPadding: 8,
                  minLeadingWidth: 4,
                  leading: GFAvatar(
                    radius: 20,
                    backgroundImage: threads.contact?.photo != null
                        ? MemoryImage(threads.contact!.photo!.bytes!)
                        : null,
                    child: threads.contact?.photo != null
                        ? null
                        : const Icon(Icons.person),
                  ),
                  subtitle: Text(
                    threads.messages.last.body ?? 'empty',
                    overflow: TextOverflow.ellipsis,
                  ),
                  title: Text(
                    threads.contact?.fullName ?? threads.contact!.address!,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                  ),
                  onTap: () => Get.to(() => MessagesPages(
                        message: threads,
                      )),
                  trailing: Text(threads.messages.last.date!.toPersianDate()),
                ),
                const Divider()
              ],
            );
          },
        ),
      );
    });
  }
}
