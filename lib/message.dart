import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_tutorial/backend.dart';
import 'package:image_tutorial/const.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageScreen extends StatefulWidget {
  String otherEmail;
  MessageScreen({required this.otherEmail});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController controller = TextEditingController();
  String text = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherEmail),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(Provider.of<CustomUser>(context, listen: false).email)
              .collection(widget.otherEmail)
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      bool val = (snapshot.data!.docs[index]['sender'] ==
                          Provider.of<CustomUser>(context, listen: false)
                              .email);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: val
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: val ? Colors.lightBlueAccent : Colors.grey,
                              borderRadius: BorderRadius.only(
                                topLeft: val
                                    ? Radius.circular(25)
                                    : Radius.circular(0),
                                topRight: val
                                    ? Radius.circular(0)
                                    : Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Linkify(
                                onOpen: (link) async {
                                  Uri url = Uri.parse(link.url);
                                  await launchUrl(url);
                                },
                                text: snapshot.data!.docs[index]['message'],
                                style: kChat,
                                maxLines: 5,
                              ),
                              // child: Text(
                              //   snapshot.data!.docs[index]['message'],
                              //   maxLines: 5,
                              //   softWrap: true,
                              //   style: kChat,
                              // ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                TextField(
                  controller: controller,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      suffix: IconButton(
                        onPressed: () async {
                          Functions func = Functions();
                          controller.clear();
                          if (text != "") {
                            await func.sendMessage(
                                text,
                                Provider.of<CustomUser>(context, listen: false)
                                    .email,
                                widget.otherEmail);
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      hintText: 'Type Your Message',
                      hintStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white),
                  onChanged: (value) {
                    text = value;
                  },
                ),
              ]);
            }
          }),
    );
  }
}
