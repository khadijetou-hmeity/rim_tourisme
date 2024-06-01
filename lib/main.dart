import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rim_tourisme/firebase_options.dart';
import 'package:rim_tourisme/homepage.dart';
import 'package:rim_tourisme/login/login.dart';
import 'package:rim_tourisme/login/singup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home:FirebaseAuth.instance.currentUser== null ? Login() : SimpleProject(), 
      routes: {
      "SignUp": (context) =>SignUp(),
      "Login": (context) =>Login(),
      "homepage": (context) =>SimpleProject(),
      }
    );
  }
}
