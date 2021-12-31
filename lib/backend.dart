import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

String signedUsername = '';

class Functions {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> registerUser(
      String email, String password, String name, CustomUser user) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      CollectionReference users = firestore.collection("users");
      await users.add({
        'name': name,
        'email': email,
        'profile':
            'https://firebasestorage.googleapis.com/v0/b/image-tutorial-478aa.appspot.com/o/images%2Fuserprofile.png?alt=media&token=cb23beca-1a21-4684-8d19-97aa09adcca6',
        'bio': '',
      });
      user.changeUser(
          name,
          email,
          'https://firebasestorage.googleapis.com/v0/b/image-tutorial-478aa.appspot.com/o/images%2Fuserprofile.png?alt=media&token=cb23beca-1a21-4684-8d19-97aa09adcca6',
          '');
      return 'true';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signUser(
      String email, String password, CustomUser user) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((documentSnapshot) {
          user.changeUser(documentSnapshot['name'], email,
              documentSnapshot['profile'], documentSnapshot['bio']);
        });
      });
      return 'true';
    } catch (e) {
      return e.toString();
    }
  }

  Future uploadImage(
      File file, String name, String profile, String email) async {
    String down = '';

    FirebaseStorage _storage = FirebaseStorage.instance;
    var uuid = Uuid();
    String uid = uuid.v4();
    Reference reference = _storage.ref().child("images/$uid");
    UploadTask uploadTask = reference.putFile(file);
    await uploadTask.then((res) async {
      int count = 0;
      down = await res.ref.getDownloadURL();
      CollectionReference counti = firestore.collection('global');
      await counti
          .doc('ImagesCount')
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        count = documentSnapshot['imagecount'];
        documentSnapshot.reference.update({
          'imagecount': documentSnapshot['imagecount'] - 1,
        });
      });
      uploadUrl(down, name, count, profile, email);
    });
  }

  Future uploadUrl(
      String url, String name, int count, String profile, String email) async {
    CollectionReference urls = firestore.collection("imageurl");
    await urls.add({
      'url': url,
      'name': name,
      'count': count,
      'likedby': [],
      'profile': profile,
      'email': email,
      'comment': [],
      'commentuser': [],
    });
  }

  Future<String> uploadProfilePic(File file, String email) async {
    String down = '';

    FirebaseStorage _storage = FirebaseStorage.instance;
    var uuid = Uuid();
    String uid = uuid.v4();
    Reference reference = _storage.ref().child("images/$uid");
    UploadTask uploadTask = reference.putFile(file);
    await uploadTask.then((res) async {
      down = await res.ref.getDownloadURL();
      await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((QuerySnapshot querysnapshot) {
        for (var doc in querysnapshot.docs) {
          doc.reference.update({
            'profile': down,
          });
        }
      });
      await firestore
          .collection('imageurl')
          .where('email', isEqualTo: email)
          .get()
          .then((QuerySnapshot querysnapshot) {
        for (var doc in querysnapshot.docs) {
          doc.reference.update({
            'profile': down,
          });
        }
      });
    });
    return down;
  }

  Future keepLoggedIn(String email, CustomUser user) async {
    await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((documentSnapshot) {
        user.changeUser(documentSnapshot['name'], email,
            documentSnapshot['profile'], documentSnapshot['bio']);
      });
    });
  }

  Future addComment(String comment, String name, int count) async {
    await firestore
        .collection('imageurl')
        .where('count', isEqualTo: count)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((documentSnapshot) async {
        List<dynamic> commenti = documentSnapshot['comment'];
        List<dynamic> namei = documentSnapshot['commentuser'];
        namei.add(name);
        commenti.add(comment);
        await documentSnapshot.reference.update({
          'comment': commenti,
          'commentuser': namei,
        });
      });
    });
  }

  Future changeBio(String bio, CustomUser useri) async {
    useri.changeBio(bio);
    await firestore
        .collection('users')
        .where('email', isEqualTo: useri.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((documentSnapshot) async {
        await documentSnapshot.reference.update({
          'bio': bio,
        });
      });
    });
  }

  Future shareImage(String Imageurl) async {
    var uuid = Uuid();
    String uid = uuid.v4();
    final url = Uri.parse(Imageurl);
    final response = await http.get(url);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/${uid}.jpg';
    File(path).writeAsBytesSync(bytes);
    await Share.shareFiles([path], text: 'Hey there');
  }

  Future sendMessage(String message, String sender, String receiver) async {
    await firestore.collection('chats').doc(sender).collection(receiver).add({
      'message': message,
      'sender': sender,
      'time': Timestamp.now(),
    });
    await firestore.collection('chats').doc(receiver).collection(sender).add({
      'message': message,
      'sender': sender,
      'time': Timestamp.now(),
    });
  }

  Future chatPersonNew(String email, String otheremail) async {
    await firestore
        .collection('chats')
        .doc(email)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        if (doc['people'].contains(otheremail)) {
          return;
        }
        doc.reference.set({
          'number': doc['number'] + 1,
          'people': FieldValue.arrayUnion([otheremail]),
        }, SetOptions(merge: true));
      } else {
        doc.reference.set({
          'number': 1,
          'people': [otheremail]
        }, SetOptions(merge: true));
      }
    });
    await firestore
        .collection('chats')
        .doc(otheremail)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        if (doc['people'].contains(email)) {
          return;
        }
        doc.reference.set({
          'number': doc['number'] + 1,
          'people': FieldValue.arrayUnion([email]),
        }, SetOptions(merge: true));
      } else {
        doc.reference.set({
          'number': 1,
          'people': [email],
        }, SetOptions(merge: true));
      }
    });
  }
}
