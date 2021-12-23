import 'package:flutter/material.dart';
import 'package:image_tutorial/main.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'backend.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

ImagePicker picker = ImagePicker();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<CustomUser>(context).name),
      ),
      body: Center(
          child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("imageurl").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("HEHE No Image");
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 50),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Image.network(snapshot.data!.docs[index]['url']),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(snapshot.data!.docs[index]['name']),
                    ],
                  ),
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
    );
  }
}
