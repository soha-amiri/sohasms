import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessagesPages extends StatefulWidget {
  const MessagesPages({super.key, required this.message});
  final SmsThread message;

  @override
  State<MessagesPages> createState() => _MessagesPagesState();
}

class _MessagesPagesState extends State<MessagesPages> {
  final _smsSender = SmsSender();
  final _controller = TextEditingController();
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.secondaryHeaderColor,
        elevation: 3,
        titleSpacing: 15,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Flex(
          mainAxisSize: MainAxisSize.min,
          direction: Axis.horizontal,
          children: [
            GFAvatar(
              radius: 20,
              backgroundImage: widget.message.contact?.photo != null
                  ? MemoryImage(widget.message.contact!.photo!.bytes!)
                  : null,
              child: widget.message.contact?.photo != null
                  ? null
                  : const Icon(Icons.person),
            ),
            Flexible(
              child: ListTile(
                title: Text(
                  widget.message.contact?.fullName ??
                      widget.message.contact!.address!.toPersianDigit(),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                ),
                subtitle: Text(
                  widget.message.contact?.address?.toPersianDigit() ?? "",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      extendBody: true,
/*
      bottomSheet: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Get.theme.secondaryHeaderColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: Row(children: [
            Expanded(
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: "پیام خود را بنویسید",
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: TextStyle(
                          color: Get.theme.hintColor,
                        ),
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ))))),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _smsSender.sendSms(
                  SmsMessage(
                    widget.message.contact!.address!,
                    _controller.text,
                  ),
                );
              },
            )
          ])),
*/
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        itemCount: widget.message.messages.length,
        reverse: true,
        itemBuilder: (context, index) {
          bool isSent =
              widget.message.messages[index].kind == SmsMessageKind.Sent;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ChatBubble(
                alignment: isSent ? Alignment.topRight : Alignment.topLeft,
                margin: const EdgeInsets.symmetric(vertical: 5),
                backGroundColor:
                    isSent ? Get.theme.secondaryHeaderColor : Colors.teal,
                clipper: ChatBubbleClipper4(
                  type: isSent
                      ? BubbleType.sendBubble
                      : BubbleType.receiverBubble,
                ),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width / 2),
                  child: Text(
                    widget.message.messages[index].body ?? '',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              if (!isSent)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    widget.message.contact?.fullName ??
                        widget.message.messages[index].sender!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
