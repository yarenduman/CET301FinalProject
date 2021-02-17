import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature;
  var temperatureForecast = new List(7);
  String location = 'Izmir';
  int woeid = 2344117;
  String weatherName;
  var weatherNameForecast = new List(7);
  String weatherIcon;
  var weatherIconForecast = new List(7);
  int predictability;
  var predictabilityForecast = new List(7);
  String errorMessage = '';

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  initState() {
    super.initState();
    fetchLocation();
    fetchLocationDay();
  }

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage = "No results";
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weatherName = data["weather_state_name"];
      weatherIcon =
          data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      predictability = data["predictability"];
    });
  }

  void fetchLocationDay() async {
    var today = new DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(locationApiUrl +
          woeid.toString() +
          '/' +
          new DateFormat('y/M/d')
              .format(today.add(new Duration(days: i + 1)))
              .toString());
      var result = json.decode(locationDayResult.body);
      var data = result[0];

      setState(() {
        temperatureForecast[i] = data["the_temp"].round();
        weatherIconForecast[i] =
            data["weather_state_name"].replaceAll(' ', '').toLowerCase();
        weatherNameForecast[i] = data["weather_state_name"];
        predictabilityForecast[i] = data["predictability"];
      });
    }
  }

  void onTextFieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
    await fetchLocationDay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: temperature == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 380,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(205, 212, 228, 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextFieldSubmitted(input);
                            },
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                              hintText: 'Search another location',
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(10.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2.0,
                                    color: Color.fromRGBO(205, 212, 228, 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 20),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Center(
                          child: Image(
                            image: AssetImage('images/$weatherIcon.png'),
                            width: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            temperature.toString() + ' °C',
                            style:
                                TextStyle(color: Colors.white, fontSize: 60.0),
                          ),
                        ),
                        Center(
                          child: Text(
                            weatherName,
                            style:
                                TextStyle(color: Colors.white, fontSize: 40.0),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.white, fontSize: 60.0),
                      ),
                    ),
                    Container(
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: <Widget>[
                            for (var i = 0; i < 7; i++)
                              forecastElement(
                                  i + 1,
                                  weatherIconForecast[i],
                                  weatherNameForecast[i],
                                  temperatureForecast[i],
                                  predictabilityForecast[i]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Widget forecastElement(
    daysFromNow, weatherIcon, weatherName, temperature, predictability) {
  var now = new DateTime.now();
  var oneDayFromNow = now.add(new Duration(days: daysFromNow));
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Container(
      width: 380,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.fromRGBO(205, 212, 228, 0.2),
        borderRadius: BorderRadius.circular(10),

      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                new DateFormat.E().format(oneDayFromNow) +
                    '        ' +
                    new DateFormat.MMMd().format(oneDayFromNow),
                maxLines: 2,
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
            Expanded(
              child: Image(
                image: AssetImage('images/$weatherIcon.png'),
                width: 40,
              ),
            ),
            Expanded(
              child: Text(
                temperature.toString() + ' °C',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Text(
                weatherName,
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
            Expanded(
              child: Text(
                predictability.toString() + '%',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
