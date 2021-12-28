import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_tutorial/main.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'backend.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'const.dart';
import 'profile.dart';
import 'login.dart';
import 'comment.dart';
import 'package:cached_network_image/cached_network_image.dart';

ImagePicker picker = ImagePicker();
List<Widget> screens = [
  HomeScreen(),
  ProfileScreen(),
];

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  int curr = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: curr == 0 ? Colors.white : Colors.grey,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: curr == 1 ? Colors.white : Colors.grey,
              ),
              label: 'Profile'),
        ],
        currentIndex: curr,
        selectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            curr = index;
          });
        },
      ),
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
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              print(auth.currentUser);
              auth.signOut();
              print(auth.currentUser);
              Provider.of<CustomUser>(context, listen: false)
                  .changeUser("", "", "");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.logout,
              size: 40,
            ),
          ),
        ],
      ),
      body: screens[curr],
    );
  }
}

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
                              backgroundImage: NetworkImage(
                                  snapshot.data!.docs[index]['profile']),
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentArea(
                                  count: snapshot.data!.docs[index]['count']),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data!.docs[index]['url'],
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  if (snapshot.data!.docs[index]['likedby']
                                      .contains(Provider.of<CustomUser>(context,
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
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommentArea(
                                        count: snapshot.data!.docs[index]
                                            ['count']),
                                  ),
                                );
                              },
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                                "${snapshot.data!.docs[index]['likedby'].length} likes"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                                "${snapshot.data!.docs[index]['comment'].length} comments"),
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
              await functions.uploadImage(
                File(image.path),
                Provider.of<CustomUser>(context, listen: false).name,
                Provider.of<CustomUser>(context, listen: false).profile,
                Provider.of<CustomUser>(context, listen: false).email,
              );
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
