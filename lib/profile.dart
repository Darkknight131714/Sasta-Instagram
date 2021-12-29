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
  String bio = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  String val = await functions.uploadProfilePic(
                      File(image.path),
                      Provider.of<CustomUser>(context, listen: false).email);
                  if (val != '') {
                    Provider.of<CustomUser>(context, listen: false)
                        .changeProfile(val);
                  }
                }
              },
              child: Text("Change Profile Picture"),
            ),
            Text(
              "Your Bio",
              style: kBioProfile,
            ),
            ListTile(
              title: Text(Provider.of<CustomUser>(context).bio != ""
                  ? Provider.of<CustomUser>(context).bio
                  : "No Bio Currently"),
              trailing: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0))),
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Change Your Bio",
                                  style: kBioChange,
                                ),
                                Center(
                                  child: TextField(
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.black),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'Edit Your Info',
                                        suffix: TextButton(
                                          onPressed: () async {
                                            Functions func = Functions();
                                            await func.changeBio(
                                                bio,
                                                Provider.of<CustomUser>(context,
                                                    listen: false));
                                            Navigator.pop(context);
                                          },
                                          child: Text("Finish"),
                                        )),
                                    onChanged: (value) {
                                      bio = value;
                                    },
                                  ),
                                ),
                              ],
                            ));
                      });
                },
                icon: Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
