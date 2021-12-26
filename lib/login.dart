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
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Name",
            ),
            onChanged: (value) {
              name = value;
            },
          ),
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Email",
            ),
            onChanged: (value) {
              email = value;
            },
          ),
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Password",
            ),
            onChanged: (value) {
              password = value;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              Functions functions = Functions();
              String value = await functions.registerUser(email, password, name,
                  Provider.of<CustomUser>(context, listen: false));
              if (value == 'true') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(value)));
              }
            },
            child: Text("Register"),
          ),
          ElevatedButton(
            onPressed: () async {
              Functions functions = Functions();
              String value = await functions.signUser(email, password,
                  Provider.of<CustomUser>(context, listen: false));
              if (value == 'true') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(value)));
              }
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }
}
