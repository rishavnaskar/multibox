import 'package:flutter/material.dart';
import 'package:multibox/weather/location.dart';
import 'package:multibox/weather/networking.dart';
import 'package:weather_icons/weather_icons.dart';

const openURL = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {
  double latitude, longitude;

  Future<dynamic> getWeatherFromCityName(String cityName) async
  {
    NetworkHelper networkHelper =
    NetworkHelper('$openURL?q=$cityName&appid=88de2a373b86a7f9b5b240ec97bd6a59&units=metric');

    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async{
    Location loc = Location();
    List returnList = await loc.getCurrentLocation();
    latitude = returnList[0];
    longitude = returnList[1];

    NetworkHelper networkHelper =
    NetworkHelper('$openURL?lat=${loc.latitude}&lon=${loc.longitude}&appid=88de2a373b86a7f9b5b240ec97bd6a59&units=metric');

    var weatherData = await networkHelper.getData();
    return [weatherData, latitude, longitude];
  }

  getWeatherIcon(int condition) {
    if (condition < 300) {
      return WeatherIcons.cloud;
    } else if (condition < 400) {
      return WeatherIcons.raindrop;
    } else if (condition < 600) {
      return WeatherIcons.rain_wind;
    } else if (condition < 700) {
      return WeatherIcons.snow;
    } else if (condition < 800) {
      return WeatherIcons.day_cloudy;
    } else if (condition == 800) {
      return WeatherIcons.day_sunny;
    } else if (condition <= 804) {
      return WeatherIcons.day_cloudy;
    } else {
      return WeatherIcons.alien;
    }
  }

  getMessage(var temp) {
    if (temp > 25) {
      return ['It\'s 🍦 time!', Colors.yellow];
    } else if (temp > 20) {
      return ['Time for shorts and 👕', Colors.grey];
    } else if (temp < 10) {
      return ['You\'ll need 🧣 and 🧤', Colors.white];
    } else {
      return ['Bring a 🧥 just in case', Colors.indigo[900]];
    }
  }
}