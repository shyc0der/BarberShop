import 'package:barber_shop/model/image_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<ImageModel>> getUserImages() async {
  List<ImageModel> imageModel = new List<ImageModel>.empty(growable: true);
  CollectionReference imageRef =
      FirebaseFirestore.instance.collection('Banner');
  QuerySnapshot snapshot = await imageRef.get();
  snapshot.docs.forEach((element) {
    imageModel.add(ImageModel.fromJson(element.data()));
  });
  return imageModel;
}
