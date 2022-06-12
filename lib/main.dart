import 'package:flutter/material.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

CustomUser mainuser = CustomUser();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool val = false;
  @override
  void initState() {
    super.initState();
  }

  Future idk() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    Functions functions = Functions();
    await functions.keepLoggedIn(auth.currentUser!.email.toString(), mainuser);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomUser>(
      create: (context) {
        return mainuser;
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          colorScheme:
              ThemeData.dark().colorScheme.copyWith(primary: Colors.orange),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              final FirebaseAuth auth = FirebaseAuth.instance;
              Functions functions = Functions();
              functions.keepLoggedIn(
                  auth.currentUser!.email.toString(), mainuser);
              String temp = auth.currentUser!.email.toString();
              temp = temp.replaceAll('@', '_');
              FirebaseMessaging.instance.subscribeToTopic(temp);
              return SecondScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
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
