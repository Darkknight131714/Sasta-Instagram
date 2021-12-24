import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_tutorial/main.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'backend.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'const.dart';

ImagePicker picker = ImagePicker();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black38,
          title: Text(
            "Sasta Instagram",
            style: kTitle,
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.chat_bubble_2,
                size: 40,
              ),
            )
          ],
        ),
        body: Center(
            child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("imageurl")
              .orderBy('count')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("HEHE No Image");
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage("images/userprofile.png"),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              snapshot.data!.docs[index]['name'],
                              style: kName,
                            ),
                          ],
                        ),
                      ),
                      Image.network(snapshot.data!.docs[index]['url']),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(children: [
                              IconButton(
                                  onPressed: () async {
                                    if (snapshot.data!.docs[index]['likedby']
                                        .contains(Provider.of<CustomUser>(
                                                context,
                                                listen: false)
                                            .email)) {
                                      await snapshot.data!.docs[index].reference
                                          .update({
                                        'likedby': FieldValue.arrayRemove([
                                          Provider.of<CustomUser>(context,
                                                  listen: false)
                                              .email
                                        ]),
                                      });
                                    } else {
                                      print(snapshot.data!.docs[index]
                                          ['likedby']);
                                      await snapshot.data!.docs[index].reference
                                          .update({
                                        'likedby': FieldValue.arrayUnion([
                                          Provider.of<CustomUser>(context,
                                                  listen: false)
                                              .email
                                        ]),
                                      });
                                    }
                                  },
                                  icon: snapshot.data!.docs[index]['likedby']
                                          .contains(Provider.of<CustomUser>(
                                                  context,
                                                  listen: false)
                                              .email)
                                      ? Icon(
                                          CupertinoIcons.heart_fill,
                                          color: Colors.red,
                                          size: 35,
                                        )
                                      : Icon(
                                          CupertinoIcons.heart,
                                          size: 35,
                                        )),
                              Text(
                                  "${snapshot.data!.docs[index]['likedby'].length} likes"),
                            ]),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                CupertinoIcons.chat_bubble,
                                size: 35,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                CupertinoIcons.share,
                                size: 35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        indent: 100,
                        endIndent: 100,
                        thickness: 2,
                        color: Colors.white,
                      ),
                    ],
                  );
                },
              );
            }
          },
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Functions functions = Functions();
              await functions.uploadImage(File(image.path),
                  Provider.of<CustomUser>(context, listen: false).name);
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
