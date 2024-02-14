import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donutcoffee/logins/signup.dart';
import 'package:donutcoffee/shopGeoPosition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';                                    // new
import 'package:firebase_core/firebase_core.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'; // new
import 'package:fluttertoast/fluttertoast.dart';   // new




class CoffeeDetailPageScreen extends StatefulWidget{
  final String coffeeName;
  const CoffeeDetailPageScreen({super.key , required this.coffeeName});

  @override
  CoffeeDetailPageScreenState createState()=> CoffeeDetailPageScreenState();
}

class CoffeeDetailPageScreenState extends State<CoffeeDetailPageScreen>{

  bool dataGet = false;
  String coffeeDescription = "";
  String coffeePrepTime = "";
  String coffeeCalories = "";
  String coffeeProteins = "";
  String coffeeCost = "";
  List<String> coffeeIngredients = [];

  String uid(auth){
    final User? user = auth.currentUser;
    final userid =user!.uid;
    String u_id = userid;
    return u_id;
  }

  Future<void> getDataCoffee(FirebaseAuth auth) async{
    CollectionReference collectiontogetFavorites = FirebaseFirestore.instance.collection('data').doc('assortments').collection('data');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectiontogetFavorites.get();
    // Get data from docs and it will be json string
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var coffeeItem in allData){
      if(coffeeItem is Map<String,dynamic>){
        String name = coffeeItem["name"];
        if(name == widget.coffeeName){
          //working with data =>
          coffeeCost = coffeeItem["price"];
          coffeeDescription = coffeeItem["description"];
          coffeePrepTime = coffeeItem["time"];
          coffeeCalories = coffeeItem["Calories"];
          coffeeProteins = coffeeItem["Proteins"];
          var listIngredients = coffeeItem["Ingredients"];
          for(var item in listIngredients){
            if(item is String){
              coffeeIngredients.add(item);
            }
          }
          break;
        }
      }
    }

    setState(() {

    });
  }

  Future<void> getData() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    await getDataCoffee(auth);
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
    double mainSizedBoxHeightUserNotLogged = height - statusBarHeight;
    return (dataGet)? Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Container(
            width: width,
            height: mainSizedBoxHeightUserNotLogged,
            color: Colors.pink.shade200,
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
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Text(
                            "Back", textAlign: TextAlign.start,
                            style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                fontSize: 28,color: Colors.white , fontWeight: FontWeight.bold))
                        ),
                      )
                  ),
                  const SizedBox(height: 20,),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Text(
                            widget.coffeeName, textAlign: TextAlign.start,
                            style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                fontSize: 24,color: Colors.white , fontWeight: FontWeight.bold))
                        ),
                      )
                  ),
                  const SizedBox(height: 5,),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          width: width*0.55,
                          child: Text(
                              coffeeDescription, textAlign: TextAlign.start,
                              style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                  fontSize: 18,color: Colors.white , fontWeight: FontWeight.w400))
                          ),
                        ),
                      )
                  ),
                  const SizedBox(height: 30,),
                  Stack(
                    clipBehavior: Clip.none, fit: StackFit.loose,
                    children: [
                      Container(
                        width: width,
                        height: mainSizedBoxHeightUserNotLogged*0.7,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(250, 250, 250, 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Text(
                                  "Preparation time: $coffeePrepTime", textAlign: TextAlign.start,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 20,color: Colors.black , fontWeight: FontWeight.w600))
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Text(
                                  "Cost: $coffeeCost", textAlign: TextAlign.start,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 20,color: Colors.black , fontWeight: FontWeight.w600))
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                  "Contains : ", textAlign: TextAlign.start,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 24,color: Colors.black , fontWeight: FontWeight.w600))
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child:  Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.mugHot , color: Colors.brown.shade500, size: 24,),
                                  const SizedBox(width: 10,),
                                  Text(
                                      "Calories: $coffeeCalories", textAlign: TextAlign.start,
                                      style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                          fontSize: 18,color: Colors.black , fontWeight: FontWeight.w400))
                                  ),
                                ],
                              )
                            ),
                            const SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.mugHot , color: Colors.brown.shade500, size: 24,),
                                  const SizedBox(width: 10,),
                                  Text(
                                      "Proteins: $coffeeProteins", textAlign: TextAlign.start,
                                      style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                          fontSize: 18,color: Colors.black , fontWeight: FontWeight.w400))
                                  ),
                                ],
                              )
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                  "Ingredients: ", textAlign: TextAlign.start,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 24,color: Colors.black , fontWeight: FontWeight.w600))
                              ),
                            ),
                            const SizedBox(height: 5,),
                            SizedBox(
                              width: width,
                              child: ListView.builder(
                                  padding: const EdgeInsets.all(0),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: coffeeIngredients.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context, int id){
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.envira , color: Colors.green.shade500, size: 24,),
                                          const SizedBox(width: 10,),
                                          Text(
                                              coffeeIngredients[id], textAlign: TextAlign.start,
                                              style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                                  fontSize: 18,color: Colors.black , fontWeight: FontWeight.w400))
                                          ),
                                        ],
                                      )
                                    );
                                  }
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: width*0.95,
                                height: mainSizedBoxHeightUserNotLogged*0.065,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                        ShopGeoPosPageScreen(coffeeName: widget.coffeeName,)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.brown.shade500, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Border radius
                                    ),
                                  ),
                                  child: Text(
                                      "Make order!", textAlign: TextAlign.start,
                                      style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                          fontSize: 18,color: Colors.white , fontWeight: FontWeight.w400))
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          left: 0.6*width,
                          top: -height*0.2,
                          child: Container(
                              height: 0.3*height,
                              width: 0.4*width,
                              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/coffee.png"), fit: BoxFit.fitHeight))
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,)
                ],
              ),
            )
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
