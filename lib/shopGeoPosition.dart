import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donutcoffee/logins/signup.dart';
import 'package:donutcoffee/userData/userPage.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';   // new


class Store {
  String email;
  String name;
  String lat;
  String long;
  String address;
  String phone;

  Store({
    required this.email,
    required this.name,
    required this.lat,
    required this.long,
    required this.address,
    required this.phone,
  });
}

class ShopGeoPosPageScreen extends StatefulWidget{
  final String coffeeName;
  const ShopGeoPosPageScreen({super.key , required this.coffeeName});

  @override
  ShopGeoPosPageScreenState createState()=> ShopGeoPosPageScreenState();
}

class ShopGeoPosPageScreenState extends State<ShopGeoPosPageScreen>{

  bool dataGet = false;
  List<Store> storeLists = [];

  final Set<Marker> _markers = Set();

  String uid(auth){
    final User? user = auth.currentUser;
    final userid =user!.uid;
    String u_id = userid;
    return u_id;
  }

  Future<void> getDataCoffee(FirebaseAuth auth) async{
    CollectionReference collectiontogetFavorites = FirebaseFirestore.instance.collection('data').doc('stores').collection('store');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectiontogetFavorites.get();
    // Get data from docs and it will be json string
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var storeItem in allData){
      print(storeItem);
      if(storeItem is Map<String,dynamic>){
          Store store = Store(name: storeItem["name"],
              lat: storeItem["lat"],
              long: storeItem["lon"],
              address: storeItem["address"],
              phone: storeItem["phone"],
              email: storeItem["email"]
          );
          storeLists.add(store);
      }
    }

    setState(() {

    });
  }

  Future<void> getData() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    await getDataCoffee(auth);
    _addMarkers();
    setState(() {
      dataGet = true;
    });
  }

  void _addMarkers() {
    // Add markers for needed locations
    for(var store in storeLists){
      double latitude = double.parse(store.lat);
      print("DATA LAT : $latitude");
      double longitude = double.parse(store.long);
      print("DATA LON : $longitude");
      String name = store.name;
      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
              title: name,
              anchor: const Offset(1,1)
          ),
          zIndex: 0,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
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
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width,
                    height: mainSizedBoxHeightUserNotLogged*0.925,
                    child: GoogleMap(
                      mapType: MapType.terrain,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(storeLists[0].lat), double.parse(storeLists[0].long)), // Initial map center
                        zoom: 16, // Initial zoom level
                      ),
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        // Controller to interact with the map
                        // Add your markers based on the needed locations
                        print("Map created!");
                      },
                    ),
                  ),
                  Container(
                    width: width,
                    height: mainSizedBoxHeightUserNotLogged*0.075,
                    color: Colors.grey.shade50,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: width*0.9,
                        height: mainSizedBoxHeightUserNotLogged*0.075,
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return MyBottomSheetContent(width: width,
                                  height: mainSizedBoxHeightUserNotLogged,
                                  storeList: storeLists, coffeeName: widget.coffeeName,);
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.blueAccent.shade400, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                          child: Text(
                              "Show shops", textAlign: TextAlign.start,
                              style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                  fontSize: 18,color: Colors.white , fontWeight: FontWeight.w400))
                          ),
                        ),
                      ),
                    ),
                  )
                ],
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

class MyBottomSheetContent extends StatelessWidget {
  final double width;
  final double height;
  final List<Store> storeList;
  final String coffeeName;
  const MyBottomSheetContent({super.key, required this.width , required this.height, required this.storeList, required this.coffeeName});

  String nameUser (FirebaseAuth auth){
    final User? user = auth.currentUser;
    final uid = user!.displayName;
    String string = uid!;
    return string;
  }

  String uid(auth){
    final User? user = auth.currentUser;
    final userid =user!.uid;
    String u_id = userid;
    return u_id;
  }

  Future<void> _showExitConfirmationDialog(BuildContext context, String coffeeName ,String storeName, String addressCoffeeStore, String storeEmail) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Buy'),
          content: Text('You buy $coffeeName at $storeName placed on $addressCoffeeStore'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const UserScreen()),(route)=>false);
                //we need to register our order at ourself and at magazine =>
                final FirebaseAuth auth = FirebaseAuth.instance;
                CollectionReference collectiontogetFavorites = FirebaseFirestore.instance.collection('users').doc(uid(auth)).collection('orders');
                String userName = nameUser(auth);
                String uidUser = uid(auth);
                // write data to collection favorites ->
                collectiontogetFavorites.add({
                  'productName': coffeeName,
                  'productHolder' : userName,
                  'storeName' : storeName,
                  'storeAddress': addressCoffeeStore,
                  'UID' : uidUser
                });
                //todo => need to add same order to store : =>
                CollectionReference collectionToAddOrderToStore = FirebaseFirestore.instance.collection('data').doc('stores').collection('store');
                CollectionReference collectionToAddOrderToStoreMore = collectionToAddOrderToStore.doc(storeEmail).collection('orders');

                // write data to collection favorites ->
                collectionToAddOrderToStoreMore.add({
                  'productName': coffeeName,
                  'productHolder' : userName,
                  'storeName' : storeName,
                  'storeAddress': addressCoffeeStore,
                  'UID' : uidUser
                });

              },
              child: Text('Confirm', style: TextStyle(color: Colors.greenAccent.shade400),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.redAccent.shade200),),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height*0.75,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                child: Text(
                    "All shops", textAlign: TextAlign.center,
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
                    itemCount: storeList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int id){
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5 , vertical: 7.5),
                          child: GestureDetector(
                            onTap: (){
                              _showExitConfirmationDialog(context, coffeeName, storeList[id].name , storeList[id].address, storeList[id].email);
                            },
                            child: ListTile(
                              leading: Icon(Icons.local_cafe , color: Colors.brown.shade300, size: 26,),
                              title: Text(
                                  storeList[id].name, textAlign: TextAlign.start,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 22,color: Colors.black , fontWeight: FontWeight.w600))
                              ),
                              subtitle: Text(
                                  "${storeList[id].address}, ${storeList[id].phone}", textAlign: TextAlign.start,
                                  style: GoogleFonts.comicNeue(textStyle: const TextStyle(
                                      fontSize: 16,color: Colors.black , fontWeight: FontWeight.w600))
                              ),
                              trailing: Icon(Icons.shopping_cart_checkout_outlined , color: Colors.green.shade300, size: 28,),
                            ),
                          )
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}