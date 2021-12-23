import 'package:flutter/material.dart';
import 'backend.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String name = "", email = "", password = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LOGIN SCREEN"),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Name",
            ),
            onChanged: (value) {
              name = value;
            },
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Email",
            ),
            onChanged: (value) {
              email = value;
            },
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Password",
            ),
            onChanged: (value) {
              password = value;
            },
          ),
          ElevatedButton(
            onPressed: () {
              Functions functions = Functions();
              functions.registerUser(email, password, name,
                  Provider.of<CustomUser>(context, listen: false));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("Register"),
          ),
          ElevatedButton(
            onPressed: () {
              Functions functions = Functions();
              functions.signUser(email, password,
                  Provider.of<CustomUser>(context, listen: false));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }
}
