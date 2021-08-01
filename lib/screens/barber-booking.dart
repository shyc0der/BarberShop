import 'package:barber_shop/cloud_firestore/salons_ref.dart';
import 'package:barber_shop/model/barber_model.dart';
import 'package:barber_shop/model/city_model.dart';
import 'package:barber_shop/model/salon_model.dart';
import 'package:barber_shop/state/state_management.dart';
import 'package:barber_shop/utils/mediaquerysizes.dart';
import 'package:barber_shop/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerWidget {
  GlobalKey<ScaffoldState> globalKey=new GlobalKey();
  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch= watch(selectedSalon).state;
    var barberWatch= watch(selectedBarber).state;
    var dayWatch=watch(selectedDay).state;
    var timeWatch=watch(selectedTime).state;
    var timeSlotWatch=watch(selectedTimeSlot).state;
    return SafeArea(
        child: Scaffold(
          key: globalKey,
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
              Expanded(
                flex: 10,
                child:
              step == 1 ? displayCities() :
              step == 2 ? displaySalons(cityWatch.name) :
              step == 3 ? displayBarbers(salonWatch) :
              step == 4 ? displayTimeSlot(context,barberWatch) :
              step== 5 ?  displayConfirmedBookedDays(context)
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
                          onPressed:
                              (step == 1 && cityWatch.name == null )   ||
                              (step == 2 && salonWatch.docId== null )  ||
                              (step == 3 && barberWatch.docId== null)  ||
                              (step ==4 && timeSlotWatch == -1 )
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
    trailing: context.read(selectedSalon).state== salons[index] ? Icon(Icons.check,color: Colors.black,) : null,
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

    displayBarbers(SalonModel salonModel) {
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
                        onTap: ()=> context.read(selectedBarber).state=barbers[index],
                        child: Card(child: ListTile(
                        leading: Icon(Icons.person,color: Colors.black,),
                          trailing: context.read(selectedBarber).state == barbers[index] ? Icon(Icons.check) : null,
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
                            onRatingUpdate: (value){},
                              ),


                      ))


                      );
                    });
              }
            }
    }
      );
    }

  displayTimeSlot(BuildContext context,BarberModel barberModel) {
 var now =context.read(selectedDay).state;
 return Column(
   children: [
     Container(
       color: Color(0xFF008577),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           Expanded(child:
             Center(child: Padding(padding: const EdgeInsets.all(16),
             child: Column(children: [
               Text('${DateFormat.MMMM().format(now)}',style: GoogleFonts.robotoMono(color: Colors.white54),),
               Text('${now.day}',style: GoogleFonts.robotoMono(color:Colors.white,fontWeight: FontWeight.bold,
               fontSize: displayHeight(context )* 0.022),),
               Text('${DateFormat.EEEE().format(now)}',
               style: GoogleFonts.robotoMono(color: Colors.white54),)
             ],),
             ),),),
           GestureDetector(onTap: ()=>
             DatePicker.showDatePicker(context,showTitleActions: true, minTime: now,maxTime: now.add(Duration(days: 31),),
                 onConfirm:(date) =>context.read(selectedDay).state =date ),
             child: Padding(
             padding: const EdgeInsets.all(8.00),
             child: Align(
               alignment: Alignment.centerRight,
               child: Icon(Icons.calendar_today,color: Colors.white,),
             ),
           ),)
         ],
       ),
     ),
     Expanded(
       child:FutureBuilder(
         future: getTimeSlotOfBarber(barberModel, DateFormat('dd_MM_yyyy').format(context.read(selectedDay).state)),
         builder: (context,snapshot){
           if(snapshot.connectionState ==ConnectionState.waiting){
             return Center(child:CircularProgressIndicator());
           }
             else {
               var listTimeSlot = snapshot.data as List<int>;
               return GridView.builder(
                   itemCount: TIME_SLOT.length,
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                   itemBuilder:(context,index)=>
                       GestureDetector(
                         onTap: listTimeSlot.contains (index)  ? null : () {
                           context.read(selectedTime).state =TIME_SLOT.elementAt(index);
                           context.read(selectedTimeSlot).state=index;
                         },
                         child:Card(
                           color: listTimeSlot.contains(index) ? Colors.white10 :
                           context.read(selectedTime).state == TIME_SLOT.elementAt(index) ? Colors.white54 :Colors.white,
                           child:GridTile(
                               child: Center(
                                   child:Column(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text('${TIME_SLOT.elementAt(index)}',style:TextStyle(fontWeight: FontWeight.bold)),
                                       Text(listTimeSlot.contains(index) ?'Booked' : 'Available',style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),),
                                     ],
                                   )
                               ),
                               header: context.read(selectedTime).state == TIME_SLOT.elementAt(index)  ? Icon(Icons.check,color: Colors.black,) : null
                           ),
                         ),)


               );
           }
           }

       )
       ,
     )

   ],
 );

  }

  confirmBooking(BuildContext context) {
    var hour=context.read(selectedTime).state.length <= 10 ?
    int.parse(context.read(selectedTime).state.split(':')[0].substring(0,1)):
    int.parse(context.read(selectedTime).state.split(':')[0].substring(0,2));
    var minutes=context.read(selectedTime).state.length <= 10 ?
    int.parse(context.read(selectedTime).state.split(':')[1].substring(0,1)) :
    int.parse(context.read(selectedTime).state.split(':')[1].substring(0,2));
    var timestamp=DateTime(
      context.read(selectedDay).state.year,
      context.read(selectedDay).state.month,
      context.read(selectedDay).state.day,
      hour,
      minutes

    ).millisecond;
    var submitData={
      'barberId': context.read(selectedBarber).state.docId,
      'barberName':context.read(selectedBarber).state.name,
      'cityBook': context.read(selectedCity).state.name,
      'customerName' :context.read(userInformation).state.name,
      'customerPhone': FirebaseAuth.instance.currentUser.phoneNumber,
      'done' : false,
      'salonAddress':context.read(selectedSalon).state.address,
      'salonId': context.read(selectedSalon).state.docId,
      'salonName':context.read(selectedSalon).state.name,
      'slot':context.read(selectedTimeSlot).state,
      'timeStamp':timestamp,
      'time': '${context.read(selectedTime).state} -${DateFormat('dd/MM/yyyy').format(context.read(selectedDay).state)}',


    };
    context.read(selectedBarber).state.documentReference.collection
      ('${DateFormat('dd_MM_yyyy').format(context.read(selectedDay).state)}')
    .doc(context.read(selectedTimeSlot).state.toString()).set(submitData).then((value) => {
      Navigator.of(context).pop(),
      ScaffoldMessenger.of(globalKey.currentContext).showSnackBar((
      SnackBar(content: Text('Booking Successful'),)
      )),
      context.read(selectedDay).state =DateTime.now(),
      context.read(selectedBarber).state=BarberModel(),
      context.read(selectedCity).state=CityModel(),
      context.read(selectedSalon).state=SalonModel(),
      context.read(currentStep).state= 1,
      context.read(selectedTime).state='',
      context.read(selectedTimeSlot).state= -1


    })
    ;

  }

  displayConfirmedBookedDays(BuildContext context) {
    return Column(
      mainAxisAlignment:MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Padding(padding: const EdgeInsets.all(14),
        child: Image.asset('assets/images/logo.png'),
        )),
        Expanded(child: Container(
          width: MediaQuery.of(context).size.width,
          child: Card(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Thank you for booking our services'.toUpperCase(),style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),),
                Text('Booking Information'.toUpperCase(),style: GoogleFonts.robotoMono(),),
                Row(children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: displayWidth(context)*0.01,),
                  Text('${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDay).state)}'.toUpperCase(),style: GoogleFonts.robotoMono(),)
                ],),
                SizedBox(height: displayHeight(context)*0.01,),
                //Barber
                Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: displayWidth(context)*0.001,),
                     Text('${context.read(selectedBarber).state.name}',style: GoogleFonts.robotoMono(),)
                  ],
                ),
                SizedBox(height: displayHeight(context)*0.01,),
                Divider(thickness: 1,),
                //Salon
                Row(
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: displayWidth(context)*0.001,),
                    Text('${context.read(selectedSalon).state.name}',style: GoogleFonts.robotoMono(),)
                  ],
                ),
                SizedBox(height: displayHeight(context)*0.01,),
                //City
                Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: displayWidth(context)*0.001,),
                    Text('${context.read(selectedSalon).state.address}',style: GoogleFonts.robotoMono(),)
                  ],
                ),
                ElevatedButton(
                  onPressed: ()=> confirmBooking(context),child: Text('Confirm'),
             style: ButtonStyle(
               backgroundColor: MaterialStateProperty.all(Colors.black)
             ),),
                
              ],
            ),
          ),),
        ))
      ]
      ,

    );
  }
}

