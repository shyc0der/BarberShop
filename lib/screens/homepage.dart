import 'package:barber_shop/cloud_firestore/banner_ref.dart';
import 'package:barber_shop/cloud_firestore/lookbook_ref.dart';
import 'package:barber_shop/cloud_firestore/user_ref.dart';
import 'package:barber_shop/model/image_model.dart';
import 'package:barber_shop/model/user_model.dart';
import 'package:barber_shop/utils/mediaquerysizes.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0XFFDFDFDF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //HEADERS AND USER PROFILE
            FutureBuilder(
                future: getUserProfiles(
                    FirebaseAuth.instance.currentUser.phoneNumber),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var userModel = snapshot.data as UserModel;
                    return Container(
                      decoration: BoxDecoration(color: Color(0xFF383838)),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        //icon circularavartar
                        children: [
                          CircleAvatar(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                            backgroundColor: Colors.black,
                            maxRadius: 24,
                          ),
                          SizedBox(
                            width: displayWidth(context) * 0.3,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userModel.name}',
                                style: GoogleFonts.robotoMono(
                                    fontSize: displayHeight(context) * 0.022,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${userModel.address}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.robotoMono(
                                    fontSize: displayHeight(context) * 0.016,
                                    color: Colors.white),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }
                }),
            //menu ITEMS
            Padding(
                padding: const EdgeInsets.all(2),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: GestureDetector(onTap: ()=>Navigator.pushNamed(context,'/barberBooking'),
                              child:Container(
                              child: Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.book_online,
                                            size: displayHeight(context) * 0.05,
                                          ),
                                          Text(
                                            'Booking',
                                            style: GoogleFonts.robotoMono(),
                                          )
                                        ],
                                      )))))),
                      Expanded(
                          child: Container(
                              child: Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart,
                                            size: displayHeight(context) * 0.05,
                                          ),
                                          Text(
                                            'Shopping',
                                            style: GoogleFonts.robotoMono(),
                                          )
                                        ],
                                      ))))),
                      Expanded(
                          child: Container(
                              child: Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.history,
                                            size: displayHeight(context) * 0.05,
                                          ),
                                          Text(
                                            'History',
                                            style: GoogleFonts.robotoMono(),
                                          )
                                        ],
                                      )))))
                    ])),
            //Banner IMAGES
            FutureBuilder(
                future: getUserImages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  else {
                    var banners = snapshot.data as List<ImageModel>;
                    return CarouselSlider(
                        items: banners
                            .map(
                              (e) => Container(
                                  child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(e.image),
                              )),
                            )
                            .toList(),
                        options: CarouselOptions(
                            enlargeCenterPage: true,
                            aspectRatio: 3.0,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 2)));
                  }
                }),
            //TEXT
            Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Text("PIGA LOOK",
                        style: GoogleFonts.robotoMono(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                )),
            //LOOKBOOK images
            FutureBuilder(
                future: getLookBook(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  else {
                    var lookBook = snapshot.data as List<ImageModel>;
                    return Column(
                        children: lookBook
                            .map((e) => Container(
                                padding: const EdgeInsets.all(6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(e.image),
                                )))
                            .toList());
                  }
                }),
          ],
        ),
      ),
    ));
  }
}
