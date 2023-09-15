import 'dart:core';
import 'package:alarm/alarm.dart';
import 'package:alarm/service/storage.dart';
import 'package:alarm_app/ColorFile.dart';
import 'package:alarm_app/CustomDropDown.dart';
import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class setTime extends StatefulWidget {
  const setTime({super.key});

  @override
  State<setTime> createState() => setTimeState();
}

class setTimeState extends State<setTime> {
  final num = Random();
  DateTime now = DateTime.now();
  int randomNum = Random().nextInt(100) + 1;
  Time time = Time(hour: DateTime.now().hour, minute: DateTime.now().minute);
  List<String> ringtones = [
    'Classic Alarm',
    'Retro Game Emergency',
    "Alarm-Clock Beep",
    "Alert Alarm",
    "Rooster Crowing Alarm",
    "Vintage Warning Alarm"
  ];
  Map<String, String> selectedRingtone = {
    "Classic Alarm": 'assets/ringtones/alarm1.mp3',
    "Retro Game Emergency": 'assets/ringtones/alarm2.mp3',
    "Alarm-Clock Beep": 'assets/ringtones/alarm3.mp3',
    "Alert Alarm": 'assets/ringtones/alarm4.mp3',
    "Rooster Crowing Alarm": 'assets/ringtones/alarm5.mp3',
    "Vintage Warning Alarm": 'assets/ringtones/alarm6.mp3'
  };

  String audioPath = 'assets/ringtones/alarm1.mp3';
  String value = "Classic Alarm";
  String setTime = "Set Time";

  Future<void> saveToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, time.hour, time.minute);

    await firestore.collection('Alarm').add({
      'number': randomNum,
      'timestamp': dateTime,
      'value': true,
    });
  }

  setAlarm() async {
    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, time.hour, time.minute);

    final alarmSettings = AlarmSettings(
      id: randomNum,
      dateTime: dateTime,
      loopAudio: true,
      vibrate: false,
      volumeMax: true,
      fadeDuration: 3.0,
      enableNotificationOnKill: true,
      notificationTitle: "Turn Off Alarm",
      notificationBody: "Click To Turn Off Alarm",
      assetAudioPath: audioPath,
      stopOnNotificationOpen: true,
    );
    await Alarm.set(alarmSettings: alarmSettings);
    AlarmStorage.saveAlarm(alarmSettings);
  }

  showToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorsFile().backgroundColor,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            alignment: Alignment.center,
            height: 500,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black12,),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Text("Set Alarm",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 35)),
                ),
                const SizedBox(height: 50,),

                CustomDropdownButton2(
                  buttonElevation: 5,
                  hint: "Pick A Ringtone",
                  value: value,
                  dropdownItems: ringtones,
                  buttonWidth: 250,
                  dropdownWidth: 240,
                  scrollbarAlwaysShow: true,
                  iconSize: 15,
                  buttonPadding: const EdgeInsets.all(20),
                  dropdownPadding: const EdgeInsets.all(5),
                  hintAlignment: const Alignment(0, 0),
                  dropdownDecoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          colors: ColorsFile().secondaryListColors)),
                  buttonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          colors: ColorsFile().secondaryListColors)),
                  onChanged: (newValue) {
                    setState(() {
                      value = newValue!;
                    });
                    selectedRingtone.forEach((key, path) {
                      if (key == value) {
                        audioPath = path;
                      }
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.arrowDown,color: Colors.white),
                  buttonHeight: 60,
                ),

                const SizedBox(height: 50,),


                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: ColorsFile().secondaryListColors),
                    color: Colors.white,
                  ),
                  width: 250,
                  height: 60,
                  child: TextButton(
                      style: const ButtonStyle(
                        alignment: Alignment.bottomCenter,
                        elevation: MaterialStatePropertyAll(0),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          showPicker(
                            elevation: 5,
                            context: context,
                            accentColor: ColorsFile().secondaryColor,
                            cancelStyle: TextStyle(color: ColorsFile().secondaryColor,fontWeight: FontWeight.bold,fontSize: 15),
                            okStyle:  TextStyle(color: ColorsFile().secondaryColor,fontWeight: FontWeight.bold,fontSize: 15),

                            themeData: ThemeData(colorScheme: const ColorScheme.dark()),
                            unselectedColor: Colors.white,
                            okText: 'Confirm',
                            value: time,
                            sunrise: const TimeOfDay(hour: 6, minute: 0),
                            // optional
                            sunset: const TimeOfDay(hour: 18, minute: 0),
                            // optional
                            duskSpanInMinutes: 120,
                            // optional
                            onChange: (newTime) {
                              setState(() {
                                time = newTime;
                                setTime = newTime.format(context);
                              });
                            },
                          ),
                        );
                      },
                      child:  Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 20, 10),
                              child: Text(setTime,
                                  maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                            ),
                            )
                            ),
                            const Icon(FontAwesomeIcons.clock, color: Colors.white, size: 17,)
                          ],
                        ),
                      )),
                ),
                const SizedBox(
                  height: 90,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(CircleBorder()),
                            fixedSize:
                                MaterialStatePropertyAll(Size.fromRadius(30)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black)),
                        onPressed: () {
                          setAlarm();
                          saveToFirebase();
                          showToast("Alarm Successfully Added");
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.add_alarm,
                          size: 30,
                          color: Colors.white,
                        )),
                    ElevatedButton(
                        style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(CircleBorder()),
                            fixedSize:
                                MaterialStatePropertyAll(Size.fromRadius(30)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 30,
                        ))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
