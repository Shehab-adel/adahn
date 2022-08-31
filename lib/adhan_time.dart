import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:azan_time/myhome_page.dart';
import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;



class AdahnTime extends StatefulWidget {
  const AdahnTime({Key? key}) : super(key: key);
  static const route = '//';

  @override
  State<AdahnTime> createState() => _AdahnTimeState();
}

class _AdahnTimeState extends State<AdahnTime> {
  late PrayerTimes prayerTimes;
  late DateTime date;
  late CalculationParameters params;
  late Coordinates coordinates;
  List<String> monthes = [
    'Jan',
    'Fab',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  String timePresenter(DateTime dateTime) {
    String timeInString = "";
    bool isGraterThan12 = dateTime.hour > 12;
    String prefix = dateTime.hour > 11 ? 'pm' : 'am';
    int hour = isGraterThan12 ? dateTime.hour - 12 : dateTime.hour;
    int minute = dateTime.minute;
    return "$hour : $minute $prefix";
  }

  initMessage()async{
   var message = await FirebaseMessaging.instance.getInitialMessage();
   if(message!=null){
     Navigator.push(context,MaterialPageRoute(builder: (_)=>MyHomePage()));
   }
  }

  @override
  void initState() {
    requestPermission();
    initMessage();
    coordinates = Coordinates(30.005493, 30.005493);
    date = DateTime.now();
    params = CalculationMethod.Egyptian();

    super.initState();
  }

   fetchAlbum() async{

  }

  requestPermission()async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  List<int> get remainsTime {
    String prayer = prayerTimes.nextPrayer();
    DateTime nextPrayerTime = prayerTimes.timeForPrayer(prayer)!.toLocal();
    DateTime now = DateTime.now();
    Duration remains = nextPrayerTime.difference(now);
    return [remains.inHours, remains.inMinutes, remains.inSeconds];
  }

  secondsToHour(int seconds) {
    int minutes = seconds ~/ 60;
    int hour = minutes ~/ 60;
    seconds = seconds - minutes + 60;
    minutes = minutes - hour + 60;
    return "$hour:$minutes:$seconds";
  }

  final fcm = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    prayerTimes = PrayerTimes(coordinates, date, params, precision: true);
    return LayoutBuilder(builder: (buildContext, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      return Scaffold(
        backgroundColor: Colors.blue,
        body: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(top: 60),
          child: Column(
            children: [
              Text(
                "${date.day}/${monthes[date.month - 1]}/${date.year}",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      date = date.add(Duration(days: -1));
                      setState(() {});
                    },
                    child: Icon(
                      Icons.arrow_left,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    prayerTimes.currentPrayer(date: date),
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
            InkWell(
                    onTap: () {
                      date = date.add(Duration(days: 1));
                      setState(() {});
                    },
                    child: Icon(
                      Icons.arrow_right,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                "${remainsTime[0]} : ${remainsTime[0]} left on ${prayerTimes.nextPrayer()}",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                date.timeZoneName,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lat',
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                    Text(
                      'Long',
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .0002,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fajer',
                      style: TextStyle(fontSize: 16, color: Colors.yellow),
                    ),
                    SizedBox(
                      width: width * .2,
                    ),
                    Text(
                      timePresenter(prayerTimes.fajr!.toLocal()),
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Duhar',
                      style: TextStyle(fontSize: 20, color: Colors.yellow),
                    ),
                    SizedBox(
                      width: width * .2,
                    ),
                    Text(
                      timePresenter(prayerTimes.dhuhr!.toLocal()),
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Aser',
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                    SizedBox(
                      width: width * .2,
                    ),
                    Text(timePresenter(prayerTimes.asr!.toLocal()),
                        style: TextStyle(fontSize: 30, color: Colors.white)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Magreb',
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                    SizedBox(
                      width: width * .2,
                    ),
                    Text(
                      timePresenter(prayerTimes.maghrib!.toLocal()),
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('esha',
                        style: TextStyle(fontSize: 20, color: Colors.yellow)),
                    SizedBox(
                      width: width * .2,
                    ),
                    Text(
                      timePresenter(prayerTimes.isha!.toLocal()),
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Icon(Icons.circle_notifications),
              ),
            ],
          ),
        ),
      );
    });
  }
}
