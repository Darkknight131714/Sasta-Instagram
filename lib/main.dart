import 'package:flutter/material.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';

CustomUser mainuser = CustomUser();
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool val = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
      idk();
    });
  }

  Future idk() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      Functions functions = Functions();
      await functions.keepLoggedIn(
          auth.currentUser!.email.toString(), mainuser);
      setState(() {
        val = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomUser>(
      create: (context) {
        return mainuser;
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: val ? SecondScreen() : LoginScreen(),
      ),
    );
  }
}

class CustomUser extends ChangeNotifier {
  String name = '';
  String email = '';
  String profile = '';
  String bio = '';
  void changeUser(
      String newName, String newEmail, String newprofile, String newbio) {
    name = newName;
    email = newEmail;
    profile = newprofile;
    bio = newbio;
    notifyListeners();
  }

  void changeProfile(String newprofile) {
    profile = newprofile;
    notifyListeners();
  }

  void changeBio(String newbio) {
    bio = newbio;
    notifyListeners();
  }
}
