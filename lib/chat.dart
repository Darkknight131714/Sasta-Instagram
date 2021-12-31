import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'backend.dart';
import 'const.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Functions func = Functions();
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0))),
                context: context,
                builder: (BuildContext context) {
                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0))),
                      title: Text("New Chat"),
                    ),
                    body: Container(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          } else {
                            return ListView.builder(
                              itemCount: snapshot.data!.size,
                              itemBuilder: (context, index) {
                                if (snapshot.data!.docs[index]['email'] ==
                                    Provider.of<CustomUser>(context,
                                            listen: false)
                                        .email) {
                                  index++;
                                }
                                return ListTile(
                                  onTap: () async {
                                    Functions func = Functions();
                                    await func.chatPersonNew(
                                        Provider.of<CustomUser>(context,
                                                listen: false)
                                            .email,
                                        snapshot.data!.docs[index]['email']);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                              otherEmail: snapshot
                                                  .data!.docs[index]['email'])),
                                    );
                                  },
                                  title:
                                      Text(snapshot.data!.docs[index]['email']),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  );
                });
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text("All Chats"),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(Provider.of<CustomUser>(context, listen: false).email)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else {
              return ListView.builder(
                itemCount: snapshot.data!['number'],
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MessageScreen(
                                otherEmail: snapshot.data!['people'][index])),
                      );
                    },
                    title: Text(snapshot.data!['people'][index]),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
