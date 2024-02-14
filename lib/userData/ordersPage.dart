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
import 'package:fluttertoast/fluttertoast.dart';   // new

class CoffeeOrderedScreen {
  String coffeeName;
  String storeAddress;
  String storeName;

  CoffeeOrderedScreen({
    required this.coffeeName,
    required this.storeAddress,
    required this.storeName,
  });
}


class OrdersPageScreen extends StatefulWidget{
  const OrdersPageScreen({super.key});

  @override
  OrdersPageScreenState createState()=> OrdersPageScreenState();
}

class OrdersPageScreenState extends State<OrdersPageScreen>{

  bool dataGet = false;
  List<CoffeeOrderedScreen> coffeeOrderedList = [];

  String uid(auth){
    final User? user = auth.currentUser;
    final userid =user!.uid;
    String u_id = userid;
    return u_id;
  }

  Future<void> getDataOrders(FirebaseAuth auth) async{
    CollectionReference collectionToGetOrders = FirebaseFirestore.instance.collection('users').doc(uid(auth)).collection('orders');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionToGetOrders.get();
    // Get data from docs and it will be json string
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var coffeeOrdered in allData){
      if(coffeeOrdered is Map<String,dynamic>){
        CoffeeOrderedScreen coffeeOrderedScreen = CoffeeOrderedScreen(coffeeName: coffeeOrdered["productName"],
            storeAddress: coffeeOrdered["storeAddress"], storeName: coffeeOrdered["storeName"]);
        coffeeOrderedList.add(coffeeOrderedScreen);
      }
    }
  }

  Future<void> getOrders() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    await getDataOrders(auth);
    setState(() {
      dataGet = true;
    });
  }

  Widget _coffeeListCard(
      double width , double height,
      String coffeeName, String address,
      String storeName
      ) {
    return SizedBox(
        width: width,
        height: height*0.55,
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
                          color: Colors.purple.shade200
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
                                  "At : $storeName",
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 18,color: Colors.white , fontWeight: FontWeight.bold))
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(bottom: 5),child:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    address, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                        fontSize: 18,color: Color(0xFF3A4742) , fontWeight: FontWeight.bold))
                                ),
                                Container(
                                    height: 40, width: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0), color: Colors.white),
                                    child: Center(
                                        child: Icon(Icons.star,
                                            color: Colors.orangeAccent.shade200, size: 20.0)
                                    )
                                ),
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
        )
    );
  }



  @override
  void initState() {
    super.initState();
    getOrders();
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
                    child: (coffeeOrderedList.isNotEmpty)?ListView.builder(
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: coffeeOrderedList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int id){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _coffeeListCard(width, mainSizedBoxHeightUserNotLogged, coffeeOrderedList[id].coffeeName,
                                coffeeOrderedList[id].storeAddress, coffeeOrderedList[id].storeName),
                          );
                        }
                    ):
                    Center(
                      child: Text("No any ordered coffee",style: GoogleFonts.comicNeue(textStyle: const TextStyle(
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
