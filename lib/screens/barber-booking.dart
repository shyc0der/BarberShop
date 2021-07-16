import 'package:barber_shop/cloud_firestore/salons_ref.dart';
import 'package:barber_shop/model/barber_model.dart';
import 'package:barber_shop/model/city_model.dart';
import 'package:barber_shop/model/salon_model.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:barber_shop/utils/mediaquerysizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';

class BookingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch= watch(selectedSalon).state;
    var barberWatch= watch(selectedBarber).state;
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Color(0xFFFDF9EE),
          body: Column(
            children: [
              NumberStepper(
                activeStep: step - 1,
                direction: Axis.horizontal,
                enableNextPreviousButtons: false,
                enableStepTapping: false,
                numbers: [1, 2, 3, 4, 5],
                stepColor: Colors.black,
                activeStepColor: Colors.grey,
                numberStyle: TextStyle(color: Colors.white),
              ),
              //screen
              Expanded(child: step == 1 ? displayCities() : step ==2 ?
              displaySalons(cityWatch.name) : step==3 ? displayBarbers(salonWatch)
                  :Container(),),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(padding: const EdgeInsets.all(8), child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: ElevatedButton(
                          onPressed: step == 1 ? null : () =>
                          context
                              .read(currentStep)
                              .state--,
                          child: Text('Previous'))),
                      SizedBox(width: displayWidth(context) * 0.003,),
                      Expanded(child: ElevatedButton(
                          onPressed: (step == 1 && cityWatch.name ==null )||
                              (step == 2 && salonWatch.docId== null )  ||
                              (step == 3 && barberWatch.docId== null)
                          ? null : step == 5 ? null : () =>
                          context
                              .read(currentStep)
                              .state++,
                          child: Text('Next')))
                    ],
                  )),
                ),
              )
            ],
          ),
        ));
  }

  displayCities() {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }
          else {
            var cities = snapshot.data as List<CityModel>;
            if (cities == null || cities.length == 0) {
              return Center(child: Text("Cannot Load City List"));
            }
            else
              return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return
                      GestureDetector(
                          onTap: () =>
                          context
                              .read(selectedCity)
                              .state = cities[index],
                          child: Card(child: ListTile(
                            leading: Icon(
                              Icons.home_work, color: Colors.black,),
                            trailing: context
                                .read(selectedCity)
                                .state == cities[index]
                                ? Icon(Icons.check)
                                : null,
                            title: Text('${cities[index].name}',
                              style: GoogleFonts.robotoMono(),),
                          ))
                      );
                  }
              );
          }

        });
  }

  displaySalons(String cityName) {
    return FutureBuilder(
    future: getSalons(cityName),
    builder: (context, snapshot)  {
      if (snapshot.connectionState == ConnectionState.waiting)
      {
        return Center(child:CircularProgressIndicator());
    }
      else{
        var salons=snapshot.data as List<SalonModel>;
        if(salons == null || salons.length ==0){
          return Center(
          child: Text('Cannot Load Salon list'),
          );
    }
        else{
          return ListView.builder(
          itemCount: salons.length,
          itemBuilder: (context,index)
    {
      return GestureDetector(
      onTap : () => context.read(selectedSalon).state =salons[index],
      child: Card(
    child:ListTile(
    leading:Icon(Icons.home_outlined,color:Colors.black),
    trailing: context.read(selectedSalon).state== salons[index] ? Icon(Icons.check) : null,
      title: Text('${salons[index].name}',style: GoogleFonts.robotoMono(),),
      subtitle: Text ('${salons[index].address}',style: GoogleFonts.robotoMono(fontStyle: FontStyle.italic),),

    )
    ),

      );
    }

    );
    }
    }
    }
    );}

    displayBarbers(SalonModel salonModel)
    {
      return FutureBuilder(
          future: getBarbers(salonModel),
          builder: (context,snapshot){
            if(snapshot.connectionState ==ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }
            else{
              var barbers=snapshot.data as List<BarberModel>;
              if(barbers ==null || barbers.length==0){
                return Center(child: Text('Cannot load Barber List'),);
              }
              else {
                return ListView.builder(
                    itemCount: barbers.length,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        onTap: ()=> context.read(selectedBarber).state.docId=barbers[index].docId,
                        child: Card(child: ListTile(
                        leading: Icon(Icons.person,color: Colors.black,),
                          trailing: context.read(selectedBarber).state ==barbers[index] ? Icon(Icons.check) : null,
                          title: Text('${barbers[index].name}',style: GoogleFonts.robotoMono(),),
                          subtitle: RatingBar.builder
                            (
                              itemSize: 16,
                              allowHalfRating: true,
                              initialRating: barbers[index].rating,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context,_)=> Icon(Icons.star,color: Colors.amber,),
                              itemPadding: const EdgeInsets.all(4),
                              ),


                      ))


                      );
                    });
              }
            }
    }
      );
    }
}

