import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sohasms/sms/controller/sms_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final smsController = Get.find<SMSController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.secondaryHeaderColor,
        title: const Text('تنظیمات'),
        automaticallyImplyLeading: false,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Obx(() {
          return Column(
            children: [
              // Forward Number
              ListTile(
                shape: Border(bottom: BorderSide(color: Colors.grey.shade400)),
                title: const Text('تنظیم شماره ارسال پیام'),
                subtitle: const Text(
                  'ییام ها به کدام شماره ارسال شوند؟',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      smsController.forwardNumber.isEmpty
                          ? '-'
                          : smsController.forwardNumber.toPersianDigit(),
                      style: TextStyle(color: Get.theme.hintColor),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Get.theme.hintColor,
                      size: 15,
                    ),
                  ],
                ),
                onTap: () => Get.defaultDialog(
                  title: 'ورود شماره',
                  barrierDismissible: false,
                  content: ForwardNumberChoose(),
                ),
              ),
              // SIM Card
              ListTile(
                shape: Border(bottom: BorderSide(color: Colors.grey.shade400)),
                title: const Text('انتخاب سیم کارت'),
                subtitle: const Text(
                  'ییام ها از کدام سیم کارت ارسال شوند؟',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      smsController.selectedSim == 1
                          ? 'سیم  1'.toPersianDigit()
                          : 'سیم  2'.toPersianDigit(),
                      style: TextStyle(color: Get.theme.hintColor),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Get.theme.hintColor,
                      size: 15,
                    ),
                  ],
                ),
                onTap: () => Get.defaultDialog(
                    title: 'انتخاب سیم کارت', content: const SimCardChoose()),
              ),
              // Contact List
              ListTile(
                shape: Border(bottom: BorderSide(color: Colors.grey.shade400)),
                title: const Text('انتخاب مخاطبین'),
                subtitle: const Text(
                  'ییام های کدام مخاطبین فوروارد شوند؟',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    smsController.forwardAll
                        ? const Text('همه',
                            style: TextStyle(color: Colors.grey))
                        : Text(
                            smsController.selectedContacts.length
                                .toString()
                                .toPersianDigit(),
                            style: TextStyle(color: Get.theme.hintColor),
                          ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Get.theme.hintColor,
                      size: 15,
                    ),
                  ],
                ),
                onTap: () => Get.defaultDialog(
                    title: 'انتخاب مخاطبین',
                    content: const ContactsChoose(),
                    confirm: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('تایید'),
                    )),
              ),
              // Keywords
              ListTile(
                enabled: false,
                shape: Border(bottom: BorderSide(color: Colors.grey.shade400)),
                title: const Text('انتخاب کلید واژه'),
                subtitle: const Text(
                  'انتخاب کلیدواژه برای فوروارد پیام ها',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Get.theme.hintColor,
                  size: 15,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ForwardNumberChoose extends StatefulWidget {
  ForwardNumberChoose({super.key});

  @override
  State<ForwardNumberChoose> createState() => _ForwardNumberChooseState();
}

class _ForwardNumberChooseState extends State<ForwardNumberChoose> {
  late final _numberController;
  final smsController = Get.find<SMSController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _numberController =
        TextEditingController(text: smsController.forwardNumber);
  }

  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _key,
        child: Column(
          children: [
            TextFormField(
              textDirection: TextDirection.ltr,
              autofocus: true,
              controller: _numberController,
              validator: (value) {
                if (value!.length != 11) {
                  return 'شماره وارد شده نامعتبر است';
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: const InputDecoration(
                hintText: '09xxxxxxxxx',
                hintStyle: TextStyle(fontSize: 14),
                helper: Text(
                  'شماره ای که پیام ها به آن هدایت می شوند.',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
              onFieldSubmitted: (value) async {
                await smsController.changeForwardNumber(_numberController.text);
                Get.back();
              },
            ),
            const SizedBox(height: 10),
            TextButton(
                onPressed: () async {
                  if (_key.currentState!.validate()) {
                    await smsController
                        .changeForwardNumber(_numberController.text);
                    Get.back();
                  }
                },
                child: Text('تایید'))
          ],
        ),
      ),
    );
  }
}

class ContactsChoose extends StatefulWidget {
  const ContactsChoose({super.key});

  @override
  State<ContactsChoose> createState() => _ContactsChooseState();
}

class _ContactsChooseState extends State<ContactsChoose> {
  var smsController = Get.find<SMSController>();

  List<MapEntry> contacts = [];
  Future<void> requestContactsPermission() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      // Permission granted, proceed to fetch contacts
      contacts = smsController.contactNumbers.entries.toList();

      setState(() {});
    } else {
      // Permission denied
      Fluttertoast.showToast(
          msg: 'برای دریافت مخاطبین دسترسی لازم راصادر کنید');
      Get.back();
      requestContactsPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestContactsPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: CheckboxMenuButton(
              value: smsController.forwardAll,
              onChanged: (all) => smsController.changeForwardAll(all!),
              child: Text('هدایت همه شماره ها'),
            ),
          ),
          Flexible(
              child: DropdownSearch<MapEntry>.multiSelection(
            enabled: !smsController.forwardAll,
            items: (filter, loadProps) => contacts,
            selectedItems: contacts
                .where(
                  (MapEntry element) =>
                      smsController.selectedContacts.contains(element.value),
                )
                .toList(),
            // selectedItems: contacts
            //     .where(
            //       (fc.Contact contact) => smsController.selectedContacts
            //           .contains(contact.phones.isNotEmpty
            //               ? contact.phones.first.number.fixPhoneNumber()
            //               : ''),
            //     )
            //     .toList(),
            itemAsString: (MapEntry item) => item.key,
            compareFn: (item, selectedItem) => item.key == selectedItem.key,
            // filterFn: (item, filter) {
            //   print(filter);
            //   return item.displayName.contains(filter) ||
            //       item.phones.first.number.contains(filter);
            // },
            onChanged: (value) {
              // smsController.changeSelectedContacts(
              //     value.map((fc.Contact e) => e.phones.first.number).toList());
              smsController.changeSelectedContacts(
                  value.map((MapEntry e) => e.value as String).toList());
            },
            popupProps: PopupPropsMultiSelection.menu(
                showSearchBox: true,
                searchDelay: const Duration(milliseconds: 500),
                showSelectedItems: true,
                textDirection: TextDirection.rtl,
                itemBuilder: (context, MapEntry item, isDisabled, isSelected) {
                  return ListTile(
                    title: Text(
                      item.key,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(item.value,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                    shape: isSelected
                        ? Border(
                            right: BorderSide(color: Get.theme.primaryColor))
                        : null,
                    /*leading: GFAvatar(
                        radius: 15,
                        backgroundImage: item.photo != null
                            ? MemoryImage(item.photo!)
                            : null,
                        child: item.photo != null
                            ? null
                            : const Icon(
                                Icons.person,
                                size: 15,
                              ),
                      )*/
                  );
                },
                emptyBuilder: (context, searchEntry) => const Center(
                      child: Text('مخاطبی یافت نشد'),
                    ),
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'جستجو مخاطب...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )),
          )),
        ],
      );
    });
  }
}

class SimCardChoose extends StatefulWidget {
  const SimCardChoose({super.key});

  @override
  State<SimCardChoose> createState() => _SimCardChooseState();
}

class _SimCardChooseState extends State<SimCardChoose> {
  final smsController = Get.find<SMSController>();
  late int selectedSim;

  @override
  void initState() {
    super.initState();
    selectedSim = smsController.selectedSim;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          RadioMenuButton(
            value: 1,
            groupValue: smsController.selectedSim,
            onChanged: (sim) => smsController.changeSelectedSim(sim!),
            child: Text('سیم کارت 1'.toPersianDigit()),
          ),
          RadioMenuButton(
            value: 2,
            groupValue: smsController.selectedSim,
            onChanged: (sim) => smsController.changeSelectedSim(sim!),
            child: Text('سیم کارت 2'.toPersianDigit()),
          ),
        ],
      );
    });
  }
}
