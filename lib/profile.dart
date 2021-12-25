import 'package:flutter/material.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'const.dart';
import 'package:image_picker/image_picker.dart';
import 'backend.dart';
import 'dart:io';

ImagePicker picker = ImagePicker();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: CircleAvatar(
              backgroundImage:
                  NetworkImage(Provider.of<CustomUser>(context).profile),
              radius: 200,
            ),
          ),
          Text(
            Provider.of<CustomUser>(context).name,
            style: kProfileName,
          ),
          ElevatedButton(
            onPressed: () async {
              XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                Functions functions = Functions();
                String val = await functions.uploadProfilePic(File(image.path),
                    Provider.of<CustomUser>(context, listen: false).email);
                if (val != '') {
                  Provider.of<CustomUser>(context, listen: false)
                      .changeProfile(val);
                }
              }
            },
            child: Text("Change Profile Picture"),
          ),
        ],
      ),
    );
  }
}
