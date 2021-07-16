import 'package:barber_shop/screens/barber-booking.dart';
import 'package:barber_shop/screens/homepage.dart';
import 'package:barber_shop/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/homepage':
            return PageTransition(
                child: Homepage(),
                settings: settings,
                type: PageTransitionType.fade);
            break;

          case '/barberBooking':
            return PageTransition(
                child: BookingScreen(), type: PageTransitionType.fade);
            break;
          default:
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  processLogin(BuildContext context) {
    //instantiate the user
    var user = FirebaseAuth.instance.currentUser;
    //if the user hasn't logged in show login
    if (user == null) {
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()]).then((firebaseUser) async {
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        //ScaffoldMessenger.of(scaffoldState.currentContext).showSnackBar(
        //SnackBar(content: Text("Login Success"'${FirebaseAuth.instance.currentUser.phoneNumber}')));
        //Navigator.pushNamedAndRemoveUntil(context, '/homepage',(route) =>false);
        await checkLoginState(context, true, scaffoldState);
      }).catchError((e) {
        if (e is PlatformException) if (e.code ==
            FirebaseAuthUi.kUserCancelledError) {
          ScaffoldMessenger.of(scaffoldState.currentContext)
              .showSnackBar(SnackBar(content: Text('${e.message}')));
        } else {
          ScaffoldMessenger.of(scaffoldState.currentContext)
              .showSnackBar(SnackBar(content: Text("unknown error")));
        }
      });
    }
    //else show homepage
    else {
      Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
      key: scaffoldState,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/my_bg.png'),
                fit: BoxFit.cover)),
        //891765

        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: checkLoginState(context, false, scaffoldState),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    var userState = snapshot.data as LOGIN_STATE;
                    if (userState == LOGIN_STATE.LOGGED) {
                      return Container();
                    } else {
                      return ElevatedButton.icon(
                        onPressed: processLogin(context),
                        icon: Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        label: Text(
                          "LOGIN WITH PHONE",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black)),
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    ));
  }

  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin,
      GlobalKey<ScaffoldState> scaffoldState) async {
    CollectionReference userReference;
    DocumentSnapshot snapshotUser;
    var nameController, addressController;
    if (!context.read(forceReloadUser).state) {
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3))
          .then((value) => {
                FirebaseAuth.instance.currentUser
                    .getIdToken()
                    .then((token) async => {
                          print('$token'),
                          context.read(userToken).state = token,
                          userReference =
                              FirebaseFirestore.instance.collection('User'),
                          snapshotUser = await userReference
                              .doc(
                                  FirebaseAuth.instance.currentUser.phoneNumber)
                              .get(),
                          context.read(forceReloadUser).state = true,
                          if (snapshotUser.exists)
                            {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/homepage', (route) => false)
                            }
                          else
                            {
                              nameController = TextEditingController(),
                              addressController = TextEditingController(),
                              Alert(
                                context: context,
                                title: 'Update Profiles',
                                content: Column(children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.account_circle),
                                      labelText: "Name",
                                    ),
                                    controller: nameController,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.home),
                                      labelText: "Address",
                                    ),
                                    controller: addressController,
                                  ),
                                ]),
                                buttons: [
                                  DialogButton(
                                      child: Text('Cancel'),
                                      onPressed: () => Navigator.pop(context)),
                                  DialogButton(
                                      child: Text('Update'),
                                      onPressed: () => {
                                            userReference
                                                .doc(FirebaseAuth.instance
                                                    .currentUser.phoneNumber)
                                                .set({
                                              'name': nameController.text,
                                              'address': addressController.text,
                                            }).then((value) async {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(scaffoldState
                                                      .currentContext)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Update Profile Successfully')));
                                              await Future.delayed(
                                                  Duration(seconds: 1), () {
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        '/homepage',
                                                        (route) => false);
                                              });
                                            }).catchError((e) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(scaffoldState
                                                      .currentContext)
                                                  .showSnackBar(SnackBar(
                                                      content: Text('$e')));
                                            }),
                                          }),
                                ],
                              ).show()
                            }
                        })
              });
    }

    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGGEDIN;
  }
}
