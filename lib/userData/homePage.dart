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


class Coffee {
  String name;
  String description;
  String price;
  bool topWeek;
  bool topMonth;

  Coffee({
    required this.name,
    required this.description,
    required this.price,
    required this.topWeek,
    required this.topMonth,
  });
}



class HomePageScreen extends StatefulWidget{
  const HomePageScreen({super.key});

  @override
  HomePageScreenState createState()=> HomePageScreenState();
}

class HomePageScreenState extends State<HomePageScreen>{

  String userName = "";
  bool dataGet = false;
  List<Coffee> coffeeList = [];
  List<Coffee> coffeeListTopMonth = [];
  List<Coffee> coffeeListTopWeek = [];
  List<String> coffeeListFavorite = [];

  String text (FirebaseAuth auth){
    final User? user = auth.currentUser;
    final uid = user!.displayName;
    String string = uid!;
    return 'Welcome, $string ';
  }

  String uid(auth){
    final User? user = auth.currentUser;
    final userid =user!.uid;
    String u_id = userid;
    return u_id;
  }

  Future<void> getDataAssortment() async{
    CollectionReference collectionAssortments = FirebaseFirestore.instance.collection('data').doc('assortments').collection('data');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionAssortments.get();
    // Get data from docs and it will be json string
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var coffeeItem in allData){
      if(coffeeItem is Map<String,dynamic>){
        bool topWeek = coffeeItem["topweek"];
        bool topMonth = coffeeItem["topmonth"];
        Coffee coffeeFetched = Coffee(
            name: coffeeItem["name"],
            description: coffeeItem["description"],
            price: coffeeItem["price"],
            topWeek: coffeeItem["topweek"],
            topMonth: coffeeItem["topmonth"]
        );
        coffeeList.add(coffeeFetched);
        //todo :=> if top week is true :
        if(topWeek){
          coffeeListTopWeek.add(coffeeFetched);
        }
        if(topMonth){
          coffeeListTopMonth.add(coffeeFetched);
        }
      }
    }
  }

  Future<void> getDataFavorite(FirebaseAuth auth) async{
    CollectionReference collectiontogetFavorites = FirebaseFirestore.instance.collection('users').doc(uid(auth)).collection('favorites');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectiontogetFavorites.get();
    // Get data from docs and it will be json string
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var coffeeItemFavorite in allData){
      if(coffeeItemFavorite is Map<String,dynamic>){
        coffeeListFavorite.add(coffeeItemFavorite["productname"]);
      }
    }
  }

  Widget _coffeeListCard(
      double width , double height,
      String coffeeName, String description,
      String price, bool isFavorite, Color colorBackground
      ) {
    return SizedBox(
        width: width*0.45,
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
                        width: width*0.45,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            color: (isFavorite)?Colors.pink[100]: colorBackground
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
                                      if(isFavorite==true){
                                        //delete data from collection favorites ->
                                        collectiontogetFavorites.where('productname', isEqualTo: coffeeName).get().then((value) => value.docs.forEach((element) {
                                          FirebaseFirestore.instance.collection('users').doc(uid(auth)).collection('favorites').doc(element.id).delete();
                                        }));
                                        //todo => after we worked with data we need to refetch data =>
                                        coffeeListFavorite.remove(coffeeName);
                                        setState(() {

                                        });
                                      }
                                      else{
                                        // write data to collection favorites ->
                                        collectiontogetFavorites.add({
                                          'productname': coffeeName,
                                          'productdescription' : description,
                                          'productprice' : price,
                                          'productfavorited': true
                                        });
                                        //todo => after we worked with data we need to refetch data =>
                                        await getDataFavorite(auth);
                                        setState(() {

                                        });
                                      }

                                    },
                                    child: Container(
                                        height: 40, width: 40,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0), color: Colors.white),
                                        child: Center(
                                            child: Icon(Icons.favorite,
                                                color: (isFavorite) ? Colors.red: Colors.grey, size: 20.0)
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
                    left: 0.1*width,
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


  Future<void> getDataHome() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    await getDataAssortment();
    await getDataFavorite(auth);
    setState(() {
      userName = text(auth);
      dataGet = true;
    });
  }


  @override
  void initState() {
    super.initState();
    getDataHome();
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
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5,),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                          userName, textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 18 , color: Color.fromRGBO(30, 29, 33, 1),
                              letterSpacing: 0.2, fontWeight: FontWeight.w500
                          )
                      )
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                          "Assortment", textAlign: TextAlign.start,
                          style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                              fontSize: 22 , color: Colors.black , fontWeight: FontWeight.bold)
                      ))
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    height: mainSizedBoxHeightUserNotLogged*0.55,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: coffeeList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int id){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _coffeeListCard(width, mainSizedBoxHeightUserNotLogged, coffeeList[id].name,
                                coffeeList[id].description, coffeeList[id].price, coffeeListFavorite.contains(coffeeList[id].name),const Color(0xFFDAB68C)),
                          );
                        }
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                          "Top month", textAlign: TextAlign.start,
                          style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                              fontSize: 22 , color: Colors.black , fontWeight: FontWeight.bold)
                          ))
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    height: mainSizedBoxHeightUserNotLogged*0.55,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: coffeeListTopMonth.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int id){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _coffeeListCard(width, mainSizedBoxHeightUserNotLogged, coffeeListTopMonth[id].name,
                                coffeeListTopMonth[id].description, coffeeListTopMonth[id].price, coffeeListFavorite.contains(coffeeListTopMonth[id].name), Colors.deepPurpleAccent.shade200),
                          );
                        }
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                          "Top week", textAlign: TextAlign.start,
                          style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                              fontSize: 22 , color: Colors.black , fontWeight: FontWeight.bold)
                          ))
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    height: mainSizedBoxHeightUserNotLogged*0.55,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: coffeeListTopWeek.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int id){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _coffeeListCard(width, mainSizedBoxHeightUserNotLogged, coffeeListTopWeek[id].name,
                                coffeeListTopWeek[id].description, coffeeListTopWeek[id].price, coffeeListFavorite.contains(coffeeListTopWeek[id].name), Colors.greenAccent.shade200),
                          );
                        }
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    )
        :
    Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Container(
            width: width,
            height: mainSizedBoxHeightUserNotLogged,
            color: const Color.fromRGBO(250, 250, 250, 1),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(strokeWidth: 3,),
                )
              ],
            ),
          ),
        )
    );
  }
}