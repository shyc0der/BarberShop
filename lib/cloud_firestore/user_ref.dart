import 'package:barber_shop/model/user_model.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<UserModel> getUserProfiles(BuildContext context,String phone) async {
  CollectionReference userReference =
      FirebaseFirestore.instance.collection('User');
  DocumentSnapshot snapshot = await userReference.doc(phone).get();
  if (snapshot.exists) {
    var userModel = UserModel.fromJson(snapshot.data());
    context.read(userInformation).state =userModel;
    return userModel;
  } else
    return UserModel();
}
