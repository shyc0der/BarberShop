import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel{
  String name,userName,docId;
  int ratingTimes;
  double rating;
  BarberModel ({this.name,this.userName,this.rating,this.ratingTimes});
  DocumentReference documentReference;
  BarberModel.fromJson(Map<String,dynamic> json){
    name=json['name'];
    userName=json['userName'];
    rating=double.parse(json['rating']== null ? '0' :json['rating'].toString());
    ratingTimes=int.parse(json['ratingTimes']==null ? '0' :json['ratingTimes'].toString());
  }

  Map<String,dynamic>toJson(){
    Map<String,dynamic> barberModel=new Map<String,dynamic>();
    barberModel['name']=this.name;
    barberModel['userName']=this.userName;
    barberModel['rating']=this.rating;
    barberModel['ratingTimes']=this.ratingTimes;
    return barberModel;

}

}