import 'package:barber_shop/model/barber_model.dart';
import 'package:barber_shop/model/city_model.dart';
import 'package:barber_shop/model/salon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<CityModel>> getCities() async{
  var cities= new List<CityModel>.empty(growable: true);
  var citRef=FirebaseFirestore.instance.collection('Salons');
  var snapshot= await citRef.get();
  snapshot.docs.forEach((element) {
    cities.add(CityModel.fromJson(element.data()));
  });
  return cities;
}

Future<List<SalonModel>> getSalons( String cityName) async{
  var salons= new List<SalonModel>.empty(growable: true);
  var salonsRef =FirebaseFirestore.instance.collection('Salons').doc(cityName.replaceAll(' ', '')).collection('Branch');
  var snapshot =await salonsRef.get();
  snapshot.docs.forEach((element) {
    var salon=SalonModel.fromJson(element.data());
    salon.docId=element.id;
    salon.documentReference=element.reference;
    salons.add(salon);
  });
  return salons;
}

Future<List<BarberModel>>getBarbers(SalonModel salonModel) async{
  var barbers=new List<BarberModel>.empty(growable: true);
  var barbersRef=salonModel.documentReference.collection("Barber");
  var snapshot=await barbersRef.get();
  snapshot.docs.forEach((element) {
    var barber=BarberModel.fromJson(element.data());
    barber.docId=element.id;
    barber.documentReference=element.reference;
    barbers.add(barber);
  });
  return barbers;
}
Future<List<int>> getTimeSlotOfBarber(BarberModel barberModel,String date)async
{
  List<int> result=new List<int>.empty(growable: true);
 var bookingRef =barberModel.documentReference.collection(date);
QuerySnapshot snapshot=await bookingRef.get();
snapshot.docs.forEach((element) {
  result.add(int.parse(element.id));
});
return result;


}











