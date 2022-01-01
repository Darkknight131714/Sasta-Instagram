import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'const.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'backend.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentArea extends StatefulWidget {
  int count;
  CommentArea({required this.count});

  @override
  _CommentAreaState createState() => _CommentAreaState();
}

class _CommentAreaState extends State<CommentArea> {
  String comment = '';
  final myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("imageurl")
            .where('count', isEqualTo: widget.count)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data!.docs[0]['profile']),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          snapshot.data!.docs[0]['name'],
                          style: kName,
                        ),
                      ],
                    ),
                  ),
                  InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data!.docs[0]['url'],
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    maxScale: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (snapshot.data!.docs[0]['likedby'].contains(
                                  Provider.of<CustomUser>(context,
                                          listen: false)
                                      .email)) {
                                await snapshot.data!.docs[0].reference.update({
                                  'likedby': FieldValue.arrayRemove([
                                    Provider.of<CustomUser>(context,
                                            listen: false)
                                        .email
                                  ]),
                                });
                              } else {
                                await snapshot.data!.docs[0].reference.update({
                                  'likedby': FieldValue.arrayUnion([
                                    Provider.of<CustomUser>(context,
                                            listen: false)
                                        .email
                                  ]),
                                });
                              }
                            },
                            icon: snapshot.data!.docs[0]['likedby'].contains(
                                    Provider.of<CustomUser>(context,
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
                          onPressed: () {},
                          icon: Icon(
                            CupertinoIcons.chat_bubble,
                            size: 35,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            Functions func = Functions();
                            await func
                                .shareImage(snapshot.data!.docs[0]['url']);
                          },
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
                            "${snapshot.data!.docs[0]['likedby'].length} likes"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      "Comments",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs[0]['comment'].length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Text(
                              '${snapshot.data!.docs[0]['commentuser'][index]} : ',
                              style: kCommentName,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                snapshot.data!.docs[0]['comment'][index],
                                style: kComment,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: myController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment',
                      suffix: TextButton(
                        onPressed: () async {
                          Functions func = Functions();
                          await func.addComment(
                              comment,
                              Provider.of<CustomUser>(context, listen: false)
                                  .name,
                              widget.count);
                          myController.clear();
                        },
                        child: Text("Post"),
                      ),
                    ),
                    onChanged: (value) {
                      comment = value;
                    },
                  ),
                ],
              ),
            );
          }
        },
      )),
    );
  }
}
