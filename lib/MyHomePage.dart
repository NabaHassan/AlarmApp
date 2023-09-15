import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ColorFile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:alarm/service/storage.dart';
import 'package:alarm_app/set_time.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> createCacheDirectory() async {
    final Directory appCacheDir = await getTemporaryDirectory();
    final cacheDir = Directory('${appCacheDir.path}/just_audio_cache');

    if (!cacheDir.existsSync()) {
      await cacheDir.create(recursive: true);
    }
  }


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  SamplingClock samplingClock = SamplingClock();
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  int counter = 0;

  List<int> val = [];

  @override
  void initState() {
    super.initState();
    Alarm.getAlarms();
    Alarm.ringStream.stream.listen((_) => yourOnRingCallback());

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsFile().backgroundColor,

        body: SingleChildScrollView(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration:  BoxDecoration(color:ColorsFile().backgroundColor,
                     ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Alarm",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 35
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    alignment: Alignment.center,
                    height: 150,
                    width: 300,
                    decoration:  BoxDecoration(shape: BoxShape.circle,gradient:LinearGradient(colors: ColorsFile().primaryListColors)),
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      height: 150,
                      width: 400,
                      child:  const AnalogClock(
                          dialBorderWidthFactor: 0,
                          dialColor: Colors.transparent,
                          markingColor: Colors.black, dialBorderColor: Colors.white),
                    ),
                  ),
                ),
                Align(
                    alignment: AlignmentDirectional.center,
                    child: Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
                        height: 65,
                        width: 400,
                        decoration:  BoxDecoration(color:ColorsFile().backgroundColor,
                            ),
                        child: DigitalClock(
                          is24HourTimeFormat: false,
                          digitAnimationStyle: Curves.easeIn,
                          hourMinuteDigitTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w500),
                          areaAligment: AlignmentDirectional.center,
                          secondDigitTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                          amPmDigitTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                          colon: Text(
                            ":",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 25),
                          ),
                        ))),
                Align(
                    alignment: AlignmentDirectional.center,
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      height: 50,
                      width: 400,
                      decoration: BoxDecoration(color:ColorsFile().backgroundColor,
                          ),
                      child: Text(formattedDate,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 22)),
                    )),
                Container(
                    alignment: Alignment.center,
                    height: 330,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: firestore.collection("Alarm").snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(strokeWidth: 0,);
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.fromLTRB(5, 100, 5, 0),
                                  child: Text(
                                    'No Alarm Has Been Set, Please Set A Alarm.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22, fontWeight: FontWeight.w500,
                                    color: Colors.white),
                                  ),
                                ); // Handle empty data
                              }

                              List<bool> switchValues = List.filled(snapshot.data!.docs.length, false);

                              return ListView.builder(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (context, index) {
                                  var document = snapshot.data!.docs[index];

                                  var data = document.data() as Map<String, dynamic>;
                                  if (data.containsKey('timestamp')) {
                                    var timestamp = data['timestamp'] as Timestamp;
                                    var dateTime = timestamp.toDate();
                                    var formattedTime = DateFormat('hh:mm a').format(dateTime);

                                    final alarmSettings = Alarm.getAlarm(data['number']);

                                    val.add(data['number']);

                                    return Container(
                                      margin: const EdgeInsets.all(10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                                         color: Colors.greenAccent.shade400) ,
                                      child: ListTile(
                                        title: Text(formattedTime,
                                            style: const TextStyle(color: Colors.black,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold) ),
                                        contentPadding:
                                        const EdgeInsets.all(10),
                                        trailing: Switch(
                                          value: data['value'],
                                          activeColor: Colors.green.shade900,
                                          inactiveThumbColor: Colors.black,
                                          activeTrackColor: Colors.green,
                                          inactiveTrackColor: Colors.grey,
                                          onChanged: (bool newValue) {
                                            setState(() {
                                              switchValues[index] = newValue;
                                              document.reference
                                                  .update({'value': newValue});
                                            });
                                            if(newValue == true){
                                              Alarm.set(alarmSettings: alarmSettings!);
                                              setTimeState().showToast("Turned On");
                                            }
                                            else{
                                              Alarm.stop(data['number']);
                                              AlarmStorage.saveAlarm(alarmSettings!);
                                              setTimeState().showToast("Turned Off");
                                            }
                                          },
                                        ),
                                        leading: Container(
                                          height: 40,
                                          decoration: const BoxDecoration(shape: BoxShape.circle,
                                            color: Colors.black,),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              AlarmStorage.unsaveAlarm(data['number']);
                                              setTimeState().showToast("Alarm Successfully Deleted");
                                              document.reference.delete();
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const ListTile(
                                      title: Text("Missing timestamp field"),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        )
                      ],
                    )),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          CircleBorder(),
                        ),
                        minimumSize: MaterialStatePropertyAll(Size(65, 65)),
                        iconSize: MaterialStatePropertyAll(20),
                        backgroundColor: MaterialStatePropertyAll(Colors.black),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  const setTime(),
                            ));

                        createCacheDirectory();
                      },
                      child: const Icon(
                        Icons.add,
                        size: 35,
                        color: Colors.white,
                      )),
                ),
              ]),
        ),
      ),
    );
  }

  yourOnRingCallback() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      backgroundColor: Colors.white,
      title: "Alarm Ringing",
      textColor: Colors.black,
      titleColor: Colors.black,
      text: 'SNOOZE ALARM?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      barrierColor: ColorsFile().backgroundColor,
      headerBackgroundColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 5),

      onConfirmBtnTap: () async {
        BuildContext dialogContext = context;
        for (int i in val) {
          if (await Alarm.isRinging(i)) {
            Alarm.stop(i);
          }
        }
        Navigator.pop(dialogContext);
      },

      onCancelBtnTap: () {
        return Navigator.pop(context);
      },
    );
  }
}


