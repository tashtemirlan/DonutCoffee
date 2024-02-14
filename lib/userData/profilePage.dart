import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart'; // new

import '../logins/login.dart';   // new

class ProfilePageScreen extends StatefulWidget{
  const ProfilePageScreen({super.key});

  @override
  ProfilePageScreenState createState()=> ProfilePageScreenState();
}

class ProfilePageScreenState extends State<ProfilePageScreen>{

  String userName = "";
  String userUID = "";

  String text (FirebaseAuth auth){
    final User? user = auth.currentUser;
    final uid = user!.displayName;
    String string = uid!;
    return 'Welcome, $string ';
  }

  String uid(FirebaseAuth auth){
    final User? user = auth.currentUser;
    final userid =user!.uid;
    String u_id = userid;
    return 'Your UID: $u_id';
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const LoginScreen()),(route)=>false);
                await signOut();
              },
              child: const Text('Exit', style: TextStyle(color: Colors.redAccent),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getDataUser() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    setState(() {
      userName = text(auth);
      userUID = uid(auth);
    });
  }


  @override
  void initState() {
    super.initState();

    getDataUser();
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = kBottomNavigationBarHeight;
    double mainSizedBoxHeightUserNotLogged = height - bottomNavBarHeight - statusBarHeight;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Container(
          width: width,
          height: mainSizedBoxHeightUserNotLogged,
          color: const Color.fromRGBO(250, 250, 250, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                userName, textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18 , color: Color.fromRGBO(30, 29, 33, 1),
                  letterSpacing: 0.2, fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 10,),
              Text(
                userUID, textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18 , color: Color.fromRGBO(155, 155, 155, 1),
                    letterSpacing: 0.2, fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: width*0.85,
                child: TextButton(onPressed: ()async{
                  _showExitConfirmationDialog(context);
                },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.black) ,
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)))),
                  child: Text("Sign out",style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 24,color: Colors.white))),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
