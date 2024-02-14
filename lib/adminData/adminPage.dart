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

class CoffeeOrderedScreenAdmin {
  String coffeeName;
  String storeAddress;
  String storeName;
  String coffeeHolder;
  String holderUID;

  CoffeeOrderedScreenAdmin({
    required this.coffeeName,
    required this.storeAddress,
    required this.storeName,
    required this.coffeeHolder,
    required this.holderUID
  });
}


class AdminScreen extends StatefulWidget{
  final String emailStore;
  const AdminScreen({super.key , required this.emailStore});

  @override
  AdminScreenState createState()=> AdminScreenState();
}

class AdminScreenState extends State<AdminScreen>{

  bool dataGet = false;
  List<CoffeeOrderedScreenAdmin> coffeeOrderedListAdmin = [];
  List<String> ordersUID = [];

  Future<void> getOrders() async{
    CollectionReference collectionToGetOrders = FirebaseFirestore.instance.collection('data').doc('stores').collection('store');
    CollectionReference collectionToGetOrdersMore = collectionToGetOrders.doc(widget.emailStore).collection('orders');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionToGetOrdersMore.get();
    // Get data from docs and it will be json string
    final allData = querySnapshot.docs.map((doc) {
      ordersUID.add(doc.id);
      return doc.data();
    }).toList();
    for(var coffeeOrderedAdmin in allData){
      if(coffeeOrderedAdmin is Map<String,dynamic>){
        CoffeeOrderedScreenAdmin coffeeOrderedScreenAdmin = CoffeeOrderedScreenAdmin(
            coffeeName: coffeeOrderedAdmin["productName"],
            storeAddress: coffeeOrderedAdmin["storeAddress"],
            storeName: coffeeOrderedAdmin["storeName"],
            coffeeHolder: coffeeOrderedAdmin["productHolder"],
            holderUID: coffeeOrderedAdmin["UID"]);
        coffeeOrderedListAdmin.add(coffeeOrderedScreenAdmin);
      }
    }
  }

  Future<void> _showDialog(BuildContext context, String coffeeUID, String userID , String coffeeName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Completed'),
          content: const Text('Are you sure you completed to create coffee ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                print("Completed!");
                CollectionReference collectionToGetOrders = FirebaseFirestore.instance.collection('data').doc('stores').collection('store');
                CollectionReference collectionToGetOrdersMore = collectionToGetOrders.doc(widget.emailStore).collection('orders');
                //user to delte =>
                CollectionReference collectionToGetOrdersUser = FirebaseFirestore.instance.collection('users').doc(userID).collection('orders');

                var querySnapshot = await collectionToGetOrdersUser.where('productName', isEqualTo: coffeeName).get();



                //delete data from collection ->
                await collectionToGetOrdersMore.doc(coffeeUID).delete();

                for (var element in querySnapshot.docs) {
                  await collectionToGetOrdersUser.doc(element.id).delete();
                  break;
                }

                //todo => after we worked with data we need to refetch data =>
                for(var elem in coffeeOrderedListAdmin){
                  if(elem.holderUID == userID && elem.coffeeName == coffeeName){
                    coffeeOrderedListAdmin.remove(elem);
                    break;
                  }
                }
                Navigator.of(context).pop(); // Close the dialog
                setState(() {

                });
              },
              child: Text('Yes', style: TextStyle(color: Colors.greenAccent.shade400),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No', style: TextStyle(color: Colors.redAccent.shade200),),
            ),
          ],
        );
      },
    );
  }

  Widget _coffeeListCard(
      double width , double height,
      String coffeeName, String address,
      String storeName, String userName,
      String userUID , BuildContext context , String coffeeUID
      ) {
    return SizedBox(
        width: width,
        height: height*0.55,
        child: GestureDetector(
          onTap: (){
            print("Coffee get");
            _showDialog(context, coffeeUID , userUID , coffeeName);
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
                            color: Colors.orangeAccent.shade200
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
                              Text(
                                  "At : $storeName",
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 18,color: Colors.white , fontWeight: FontWeight.bold))
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                  "Client name : $userName",
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 18,color: Colors.white , fontWeight: FontWeight.bold))
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                  "Client UID : $userUID",
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 18,color: Colors.white , fontWeight: FontWeight.bold))
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                  "Coffee UID : $coffeeUID",
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 18,color: Colors.white , fontWeight: FontWeight.bold))
                              ),
                              const SizedBox(height: 5,),
                              Padding(padding: const EdgeInsets.only(bottom: 5),child:
                              Text(
                                  address, overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 18,color: Color(0xFF3A4742) , fontWeight: FontWeight.bold))
                              ),)
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


  Future<void> getData() async{
    await getOrders();
    setState(() {
      dataGet = true;
    });
  }




  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = kBottomNavigationBarHeight;
    double mainSizedBoxHeightUserNotLogged = height - bottomNavBarHeight - statusBarHeight;
    return(dataGet)? Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: mainSizedBoxHeightUserNotLogged*0.05,),
              SizedBox(
                width: width,
                child: (coffeeOrderedListAdmin.isNotEmpty)?ListView.builder(
                    padding: const EdgeInsets.all(0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: coffeeOrderedListAdmin.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int id){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _coffeeListCard(width, mainSizedBoxHeightUserNotLogged, coffeeOrderedListAdmin[id].coffeeName,
                            coffeeOrderedListAdmin[id].storeAddress, coffeeOrderedListAdmin[id].storeName,
                            coffeeOrderedListAdmin[id].coffeeHolder, coffeeOrderedListAdmin[id].holderUID,
                            context, ordersUID[id]
                        ),
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
