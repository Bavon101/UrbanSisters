import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Pages/SignIn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2 Urban Sisters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Colors.purpleAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.abelTextTheme()
      ),
      home: SignIn(),
    );
  }
}

