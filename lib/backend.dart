import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

String signedUsername = '';

class Functions {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future registerUser(
      String email, String password, String name, CustomUser user) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      CollectionReference users = firestore.collection("users");
      await users.add({
        'name': name,
        'email': email,
      });
      user.changeUser(name, email);
    } catch (e) {
      print(e);
    }
  }

  Future signUser(String email, String password, CustomUser user) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((documentSnapshot) {
          user.changeUser(documentSnapshot['name'], email);
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future uploadImage(File file, String name) async {
    String down = '';
    FirebaseStorage _storage = FirebaseStorage.instance;
    var uuid = Uuid();
    String uid = uuid.v4();
    Reference reference = _storage.ref().child("images/$uid");
    UploadTask uploadTask = reference.putFile(file);
    await uploadTask.then((res) async {
      down = await res.ref.getDownloadURL();
      uploadUrl(down, name);
    });
  }

  Future uploadUrl(String url, String name) async {
    CollectionReference urls = firestore.collection("imageurl");
    urls.add({'url': url, 'name': name});
  }
}
