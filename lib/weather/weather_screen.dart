import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multibox/weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherModel weatherModel = WeatherModel();
  IconData weatherIcon = IconData(0);
  Color tempColor;
  var temperature, wD;
  String cityName, weatherMessage, nameOfDay, countryName, phoneNo, description;
  int day, month, year, maxTemp, minTemp;
  double latitude, longitude;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    getDateTime();
    getCurrentUser();
    getRecords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCurrentUser() async {
    try {
      final user = await FirebaseAuth.instance.currentUser();
      if (user != null) {
        setState(() {
          phoneNo = user.phoneNumber;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  getRecords() async {
    final records =
        await Firestore.instance.collection('records').getDocuments();
    setState(() {
      for (var record in records.documents) {
        if (record.data['phone'] == phoneNo) {
          if (record.data['latitude'] != null &&
              record.data['longitude'] != null) {
            temperature = record.data['temperature'];
            countryName = record.data['country'];
            var condition = record.data['condition'];
            maxTemp = record.data['maxTemp'];
            minTemp = record.data['minTemp'];
            description = record.data['description'];
            cityName = record.data['cityname'];
            weatherMessage = weatherModel.getMessage(temperature)[0];
            tempColor = weatherModel.getMessage(temperature)[1];
            weatherIcon = weatherModel.getWeatherIcon(condition);
          } else {
            getLocation();
          }
        }
      }
    });
  }

  void getDateTime() {
    day = DateTime.now().day;
    month = DateTime.now().month;
    year = DateTime.now().year;

    if (DateTime.now().weekday == 1)
      nameOfDay = 'Mon';
    else if (DateTime.now().weekday == 2)
      nameOfDay = 'Tue';
    else if (DateTime.now().weekday == 3)
      nameOfDay = 'Wed';
    else if (DateTime.now().weekday == 4)
      nameOfDay = 'Thurs';
    else if (DateTime.now().weekday == 5)
      nameOfDay = 'Fri';
    else if (DateTime.now().weekday == 6)
      nameOfDay = 'Sat';
    else if (DateTime.now().weekday == 7)
      nameOfDay = 'Sun';
    else
      nameOfDay = 'None';
  }

  void getLocation() async {
    setState(() {
      showSpinner = true;
    });
    var wD = await WeatherModel().getLocationWeather();
    latitude = wD[1];
    longitude = wD[2];
    updateUI(wD[0]);
  }

  void updateUI(dynamic weatherData) async {
    final records =
        await Firestore.instance.collection('records').getDocuments();
    if (mounted) {
      setState(() {
        showSpinner = false;
        temperature = weatherData['main']['temp'];
        countryName = weatherData['sys']['country'];
        var condition = weatherData['weather'][0]['id'];
        cityName = weatherData['name'];
        minTemp = weatherData['main']['temp_min'];
        maxTemp = weatherData['main']['temp_max'];
        description = weatherData['weather'][0]['main'];
        weatherMessage = weatherModel.getMessage(temperature)[0];
        tempColor = weatherModel.getMessage(temperature)[1];
        weatherIcon = weatherModel.getWeatherIcon(condition);

        for (var record in records.documents) {
          if (record.data['phone'] == phoneNo) {
            Firestore.instance
                .collection('records')
                .document('$phoneNo')
                .updateData({
              'latitude': latitude,
              'longitude': longitude,
              'temperature': temperature,
              'minTemp': minTemp,
              'maxTemp': maxTemp,
              'description': description,
              'country': countryName,
              'condition': condition,
              'cityname': cityName,
            });
          }
        }
      });
    }
  }

  Widget weatherWidget(IconData iconData, String time) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          BoxedIcon(
            iconData,
            color: Colors.white,
            size: 30.0,
          ),
          Flexible(child: SizedBox(height: 15.0)),
          Flexible(
            child: Text(
              time,
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      opacity: 0.9,
      color: Colors.white,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.deepPurple[400], Color(0xff6B63FF)],
            begin: Alignment.topCenter,
          )),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 20.0,
                          )),
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 20.0, top: 10.0),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '${cityName == null ? '' : cityName}',
                                  style: TextStyle(
                                    fontSize: 40.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              Expanded(child: SizedBox(width: 10.0)),
                              IconButton(
                                padding: EdgeInsets.only(top: 5.0),
                                icon: Icon(Icons.near_me),
                                color: Colors.white,
                                iconSize: 30.0,
                                onPressed: () {
                                  setState(() {
                                    getLocation();
                                  });
                                },
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 20.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${countryName == null ? '' : countryName}',
                              style: TextStyle(
                                fontSize: 25.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: 20.0, top: 5.0, bottom: 5.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              '$nameOfDay $day/$month/$year',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 20.0,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                          child: SizedBox(
                        height: 10.0,
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          BoxedIcon(
                            weatherIcon == null
                                ? WeatherIcons.time_12
                                : weatherIcon,
                            color: tempColor,
                            size: 50.0,
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            '${temperature == null ? 1 : temperature}°c',
                            style: TextStyle(
                              fontSize: 35.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            (maxTemp == null && minTemp == null) ? '1' : '$maxTemp/$minTemp°',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 30.0,
                          ),
                          Text(
                            description == null ? '' : description,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        weatherMessage == null ? '' : weatherMessage,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 20.0,
                            spreadRadius: 15.0,
                            color: Colors.deepPurple[400])
                      ],
                      color: Colors.deepPurple[400],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35.0),
                        topRight: Radius.circular(35.0),
                        bottomLeft: Radius.circular(35.0),
                        bottomRight: Radius.circular(35.0),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 30.0),
                          height: MediaQuery.of(context).size.height / 2,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              weatherWidget(WeatherIcons.cloudy, '4 am'),
                              weatherWidget(WeatherIcons.cloud_down, '5 am'),
                              weatherWidget(WeatherIcons.cloud_down, '6 am'),
                              weatherWidget(WeatherIcons.day_cloudy, '7 am'),
                              weatherWidget(WeatherIcons.day_cloudy, '8 am'),
                              weatherWidget(
                                  WeatherIcons.day_light_wind, '9 am'),
                              weatherWidget(
                                  WeatherIcons.day_light_wind, '10 am'),
                              weatherWidget(
                                  WeatherIcons.day_sunny_overcast, '11 am'),
                              weatherWidget(WeatherIcons.day_sunny, '12 pm'),
                              weatherWidget(WeatherIcons.day_sunny, '1 pm'),
                              weatherWidget(WeatherIcons.day_sunny, '2 pm'),
                              weatherWidget(
                                  WeatherIcons.day_light_wind, '3 pm'),
                              weatherWidget(WeatherIcons.day_windy, '4 pm'),
                              weatherWidget(WeatherIcons.day_windy, '5 pm'),
                              weatherWidget(
                                  WeatherIcons.day_cloudy_windy, '6 pm'),
                              weatherWidget(
                                  WeatherIcons.night_alt_cloudy, '7 pm'),
                              weatherWidget(
                                  WeatherIcons.night_alt_cloudy_high, '8 pm'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(child: SizedBox(height: 5.0)),
            ],
          ),
        ),
      ),
    );
  }
}
