import 'package:barber_shop/model/image_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<ImageModel>> getLookBook() async {
  List<ImageModel> lookBookModel = new List<ImageModel>.empty(growable: true);
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('LookBook');
  QuerySnapshot querySnapshot = await collectionReference.get();

  querySnapshot.docs.forEach((element) {
    lookBookModel.add(ImageModel.fromJson(element.data()));
  });
  return lookBookModel;
}
