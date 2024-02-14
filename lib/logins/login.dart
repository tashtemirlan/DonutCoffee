import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donutcoffee/logins/signup.dart';
import 'package:donutcoffee/userData/userPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';                                    // new
import 'package:firebase_auth/firebase_auth.dart'; // new
import 'package:fluttertoast/fluttertoast.dart';

import '../adminData/adminPage.dart';   // new

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  LoginScreenState createState()=> LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>{
  bool usersigned = false;

  //bool to show password ->
  bool passwordVisible = false;

  //List to store our mails of stores :
  List<String> listStores = [];
  //VOIDS :

  //SIGN IN TO SYSTEM VIA EMAIL & PASSWORD
  void signInWithEmailAndPassword(String email, String password, void Function(FirebaseAuthException e) errorCallback) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      FirebaseAuth.instance
          .userChanges()
          .listen((User? user) {
        if (user == null) {
          //to do if user logged out
        } else {
          //to do if user signed in
          usersigned=true;
        }
      });
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: "Wrong password or email",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0
        );
      }
    }
  }

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> getStores() async{
    CollectionReference collectionGetStores = FirebaseFirestore.instance.collection('data').doc('stores').collection('store');
    QuerySnapshot querySnapshot = await collectionGetStores.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var store in allData){
      print(store);
      if(store is Map<String,dynamic>){
        listStores.add(store["email"]);
      }
    }
  }


  @override
  void initState() {
    super.initState();
    getStores();
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/try1.jpg"),
                  fit: BoxFit.cover)
          ),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: width/25 , top: height/4, right: width/25),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "Login",
                          style: GoogleFonts.comicNeue(
                              textStyle: const TextStyle(
                                  fontSize: 34, fontWeight: FontWeight.bold,color: Colors.white)
                          )
                      )
                  )
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: height/25 , horizontal: width/25),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child:  Text(
                          "Please sign in to continue" ,
                          style: GoogleFonts.comicNeue(
                              textStyle: const TextStyle(fontSize: 18,color: Colors.white)
                          )
                      )
                  )
              ),
              SizedBox(
                  width: width,
                  child: Padding(
                      padding: EdgeInsets.only(top:height/50 , right: width/25 , left: width/25),
                      child:Align(
                          alignment: Alignment.centerLeft,
                          child:TextFormField(
                              controller: email, keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  prefixIcon: Padding(
                                      padding: EdgeInsets.only() ,
                                      child: IconTheme(data: IconThemeData(color: Colors.white), child: Icon(Icons.email)
                                      )
                                  ),
                                  enabledBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  hintStyle: TextStyle(fontSize: 22 , color: Colors.white),
                                  hintText: "user1234@email.com",
                                  labelText: "EMAIL" ,
                                  labelStyle: TextStyle(fontSize: 18, color: Colors.white)
                              ),
                              style: GoogleFonts.comicNeue(
                                  textStyle: const TextStyle(fontSize: 24 , fontWeight: FontWeight.bold , color: Colors.white)
                              ),
                              validator: (String?value){
                                if(value == null ||value.isEmpty){
                                  return "PLEASE ENTER YOUR LOGIN OR EMAIL";}
                                return null;}
                              )
                      )
                  )
              ),
              //password ->
              SizedBox(width:width, child: Padding(padding: EdgeInsets.symmetric(vertical: height/50 , horizontal: width/25),child: Align(alignment: Alignment.centerLeft,
                  child:TextFormField( controller: password, keyboardType: TextInputType.text,
                      obscureText: !passwordVisible, //this will obscure text dynamically
                      decoration: InputDecoration( prefixIcon: Padding(padding: EdgeInsets.only() ,
                          child: IconTheme(data: IconThemeData(color: Colors.white), child: Icon(Icons.password))),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),hintStyle: TextStyle(fontSize: 22 , color: Colors.black),
                        hintText: "" , labelText: "PASSWORD" , labelStyle: TextStyle(fontSize: 18 , color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                      style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 24 , fontWeight: FontWeight.bold , color: Colors.white)),validator: (String?value){
                        if(value == null ||value.isEmpty){
                          return "PLEASE ENTER YOUR PASSWORD";}
                        return null;})))),
              Padding(padding:  EdgeInsets.symmetric(vertical: height/50),
                  child: SizedBox(width: width/2,height:height/20, child: ElevatedButton(onPressed:(){
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        //we have void signInWithEmailAndPassword ==> so let's use it :
                        print(listStores);
                        //todo =>
                        if(listStores.contains(email.text)){
                          //we log in to administrator =>
                          print("login as admin");
                          //after this was successfully logged in navigate it to hello page ==>
                          Future.delayed(const Duration(milliseconds: 800), () {
                            // Here you can write your code
                            if(password.text == "${email.text}password"){
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>
                                  AdminScreen(emailStore: email.text,)),(route)=>false);
                            }
                          });
                        }
                        else{
                          //login as client =>
                          signInWithEmailAndPassword(email.text, password.text, (e) { });
                          //after this was successfully logged in navigate it to hello page ==>
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            // Here you can write your code
                            User? user = FirebaseAuth.instance.currentUser;
                            if(usersigned==true && user!.emailVerified){
                              print("login as user");
                             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>
                                 const UserScreen()),(route)=>false);
                            }
                          });
                        }
                      },
                      style:ElevatedButton.styleFrom(backgroundColor: Colors.green), child:  Text("LOGIN " , style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18), color: Colors.white))
                  ),
                  )),
              Padding(padding: const EdgeInsets.only(top: 20,bottom: 10),
                  child: Align(alignment: Alignment.center,child: Text.rich(TextSpan(
                      text: "Don't have an account?", style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18,color: Colors.white)),
                      children: <TextSpan>[
                        TextSpan(text: " Sign up" , style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18 , fontWeight: FontWeight.bold , color: Colors.green)) , recognizer: TapGestureRecognizer()
                          ..onTap =(){
                            //go to sign up screen ==>
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpPage()));
                          })
                      ]
                  )))),
            ],
          )),
    );
  }
}
