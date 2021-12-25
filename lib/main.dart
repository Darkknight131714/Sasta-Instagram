import 'package:flutter/material.dart';
import 'login.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomUser>(
      create: (context) {
        return CustomUser();
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: LoginScreen(),
      ),
    );
  }
}

class CustomUser extends ChangeNotifier {
  String name = '';
  String email = '';
  String profile = '';
  void changeUser(String newName, String newEmail, String newprofile) {
    name = newName;
    email = newEmail;
    profile = newprofile;
    notifyListeners();
  }

  void changeProfile(String newprofile) {
    profile = newprofile;
    notifyListeners();
  }
}
