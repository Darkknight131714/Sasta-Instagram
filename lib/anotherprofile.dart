import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main.dart';
import 'const.dart';

class AnotherProfileScreen extends StatefulWidget {
  String email;
  AnotherProfileScreen({required this.email});

  @override
  _AnotherProfileScreenState createState() => _AnotherProfileScreenState();
}

class _AnotherProfileScreenState extends State<AnotherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: widget.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(snapshot.data!.docs[0]['profile']),
                        radius: 200,
                      ),
                    ),
                    Text(
                      snapshot.data!.docs[0]['name'],
                      style: kProfileName,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Their Bio",
                      style: kBioTitle,
                    ),
                    Text(
                      snapshot.data!.docs[0]['bio'] != ""
                          ? snapshot.data!.docs[0]['bio']
                          : "No Bio Currently",
                      style: kBio,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
