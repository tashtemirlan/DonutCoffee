import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donutcoffee/logins/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';                                    // new
import 'package:firebase_core/firebase_core.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'; // new
import 'package:fluttertoast/fluttertoast.dart';

import '../coffeeDetailPage.dart';   // new

class CoffeeFavoritedScreen {
  String name;
  String description;
  String price;

  CoffeeFavoritedScreen({
    required this.name,
    required this.description,
    required this.price,
  });
}


class FavoritePageScreen extends StatefulWidget{
  const FavoritePageScreen({super.key});

  @override
  FavoritePageScreenState createState()=> FavoritePageScreenState();
}

class FavoritePageScreenState extends State<FavoritePageScreen>{

  bool dataGet = false;
  List<CoffeeFavoritedScreen> coffeeFavorited = [];

  String uid(auth){
    final User? user = auth.currentUser;
    final userid =user!.uid;
    String u_id = userid;
    return u_id;
  }

  Future<void> getDataFavorite(FirebaseAuth auth) async{
    CollectionReference collectiontogetFavorites = FirebaseFirestore.instance.collection('users').doc(uid(auth)).collection('favorites');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectiontogetFavorites.get();
    // Get data from docs and it will be json string
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var coffeeItemFavorite in allData){
      if(coffeeItemFavorite is Map<String,dynamic>){
        CoffeeFavoritedScreen coffeeFavoritedScreen = CoffeeFavoritedScreen(name: coffeeItemFavorite["productname"],
            description: coffeeItemFavorite["productdescription"], price: coffeeItemFavorite["productprice"]);
        coffeeFavorited.add(coffeeFavoritedScreen);
      }
    }
  }


  Widget _coffeeListCard(
      double width , double height,
      String coffeeName, String description,
      String price
      ) {
    return SizedBox(
        width: width,
        height: height*0.55,
        child: GestureDetector(
          onTap: (){
            print("Tapped on coffee: $coffeeName");
            Navigator.push(context, MaterialPageRoute(builder: (context)=>
                CoffeeDetailPageScreen(coffeeName: coffeeName,)));
          },
          child: Stack(
              children: [
                Positioned(
                    top: 0.075*height,
                    child: Container(
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        height: 0.45*height,
                        width: width-10,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            color: Colors.pink[100]
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 0.075*height,
                              ),
                              SizedBox(
                                  height: 24,
                                  child: Text(
                                    'CoffeeShop\'s',
                                    style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                        fontSize: 20,color: Colors.white , fontWeight: FontWeight.bold)),
                                  )
                              ),
                              const SizedBox(height: 3),
                              SizedBox(height: 32,child: Text(
                                  coffeeName, overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 24,color: Colors.white , fontWeight: FontWeight.bold))
                              )
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                height: height*0.2,
                                child: Text(
                                    description,
                                    style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                        fontSize: 15,color: Colors.white , fontWeight: FontWeight.bold))
                                ),
                              ),
                              Padding(padding: const EdgeInsets.only(bottom: 5),child:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      price,
                                      style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                          fontSize: 25,color: Color(0xFF3A4742) , fontWeight: FontWeight.bold))
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      final FirebaseAuth auth = FirebaseAuth.instance;
                                      CollectionReference collectiontogetFavorites = FirebaseFirestore.instance.collection('users').doc(uid(auth)).collection('favorites');
                                      //delete data from collection favorites ->
                                      collectiontogetFavorites.where('productname', isEqualTo: coffeeName).get().then((value) => value.docs.forEach((element) {
                                        FirebaseFirestore.instance.collection('users').doc(uid(auth)).collection('favorites').doc(element.id).delete();
                                      }));
                                      //todo => after we worked with data we need to refetch data =>
                                      for(var elem in coffeeFavorited){
                                        if(elem.name == coffeeName){
                                          coffeeFavorited.remove(elem);
                                          break;
                                        }
                                      }
                                      setState(() {

                                      });
                                    },
                                    child: Container(
                                        height: 40, width: 40,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0), color: Colors.white),
                                        child: const Center(
                                            child: Icon(Icons.favorite,
                                                color: Colors.red, size: 20.0)
                                        )
                                    ),
                                  )
                                ],
                              ))
                            ]
                        )
                    )
                ),
                Positioned(
                    left: 0.4*width,
                    child: Container(
                        height: 0.15*height,
                        width: 0.2*width,
                        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/coffee.png"), fit: BoxFit.fitHeight))
                    )
                )
              ]
          ),
        )
    );
  }


  Future<void> getDataFavorites() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    await getDataFavorite(auth);
    setState(() {
      dataGet = true;
    });
  }


  @override
  void initState() {
    super.initState();
    getDataFavorites();
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = kBottomNavigationBarHeight;
    double mainSizedBoxHeightUserNotLogged = height - bottomNavBarHeight - statusBarHeight;
    return (dataGet)? Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Container(
            width: width,
            height: mainSizedBoxHeightUserNotLogged,
            color: const Color.fromRGBO(250, 250, 250, 1),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: width,
                    child: (coffeeFavorited.isNotEmpty)?ListView.builder(
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: coffeeFavorited.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int id){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _coffeeListCard(width, mainSizedBoxHeightUserNotLogged, coffeeFavorited[id].name,
                                coffeeFavorited[id].description, coffeeFavorited[id].price),
                          );
                        }
                    ):
                    Center(
                      child: Text("No any favorite coffee",style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                          fontSize: 20,color: Colors.black , fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    ):
    Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Container(
            width: width,
            height: mainSizedBoxHeightUserNotLogged,
            color: const Color.fromRGBO(250, 250, 250, 1),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          ),
        )
    );
  }
}
