import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:multibox/authservice.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stetho.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepPurple[700],
        accentColor: Color(0xff191CD9),
      ),
      home: AuthService().handleAuth(),
    );
  }
}