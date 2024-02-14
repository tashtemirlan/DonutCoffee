import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'firebase_options.dart';
import 'logins/login.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MaterialApp(
        theme: ThemeData(
            colorScheme: ThemeData().colorScheme.copyWith(primary: const Color.fromRGBO(77, 170, 232, 1)),
            fontFamily: 'Roboto'
        ),
        debugShowCheckedModeBanner: false, //hide debug banner
        home: LogoStart()
    ));
  });
}


class LogoStart extends StatefulWidget{
  LogoStartState createState()=> LogoStartState();
}

class LogoStartState extends State<LogoStart>{
  Future<void> logoMainMethod() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Timer(const Duration(milliseconds: 1500),()=>Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen())));
  }

  @override
  void initState() {
    super.initState();
    logoMainMethod();
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage("assets/images/Logo.jpg"),fit: BoxFit.contain)
        ),
      ),
    );
  }
}
