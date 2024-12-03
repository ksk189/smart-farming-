import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true; // Variable to track the loading state

  // Weather variables
  String _cityName = 'Fetching...';
  double _temperature = 25.0;
  double _feelsLike = 23;
  int _humidity = 40;
  int hour = DateTime.now().hour;
  int _id = 711;
  String _status = 'Smoke';
  int _pressure = 1016;
  dynamic _windspeed = 4.6;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _getWeather(position.latitude, position.longitude);
    } catch (e) {
      print("Error fetching location: $e");
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  Future<void> _getWeather(double latitude, double longitude) async {
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=81b1107152e5d4deff242d62bee2d89e&units=metric';
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _cityName = data['name'] ?? 'Unknown';
          _temperature = data['main']['temp'] ?? 0.0;
          _humidity = data['main']['humidity'] ?? 0;
          _feelsLike = data['main']['feels_like'] ?? 0.0;
          _id = data['weather'][0]['id'] ?? 0;
          _status = data['weather'][0]['main'] ?? 'Unknown';
          _pressure = data['main']['pressure'] ?? 0;
          _windspeed = data['wind']['speed'] ?? 0.0;
        });
      } else {
        print("Failed to fetch weather data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching weather data: $e");
    }
  }
  //   Future<void> _getForecast(double latitude, double longitude) async {
  //   String url =
  //       'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=81b1107152e5d4deff242d62bee2d89e&units=metric';
  //   http.Response response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body);
  //     var i = 0;
  //     while (DateTime.now().day == data['list'][i]['dt_txt']) {
  //       i++;
  //     }
  //   } else {
  //     print(response.statusCode);
  //   }
  // }


  // Function to get background color gradient based on the time of day
  List<Color> getcolors() {
    if (hour >= 6 && hour <= 11) {
      return [
        const Color.fromARGB(255, 94, 228, 237),
        const Color(0xFF3eadcf),
      ];
    } else if (hour > 11 && hour <= 16) {
      return [
        const Color(0xFFFF8000),
        const Color(0xFFFFA600),
      ];
    } else if (hour > 16 && hour < 19) {
      return [
        const Color(0xFF4e54c8),
        const Color(0xFF9795ef),
      ];
    } else {
      return [const Color(0xff34495e), const Color(0xFF01162E)];
    }
  }

  // Function to get the correct weather icon based on condition ID
  String getweatherIcon(int condition) {
    if (condition < 300) {
      return 'assets/ic_storm_weather.png';
    } else if (condition < 400) {
      return 'assets/ic_rainy_weather.png';
    } else if (condition < 600) {
      return 'assets/ic_rainy_weather.png';
    } else if (condition < 700) {
      return 'assets/ic_snow_weather.png';
    } else if (condition < 800) {
      return 'assets/ic_mostly_cloudy.png';
    } else if (condition == 800) {
      return 'assets/ic_clear_day.png';
    } else if (condition <= 804) {
      return 'assets/ic_cloudy_weather.png';
    } else {
      return 'assets/ic_unknown.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator
            : Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: getcolors(),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Weather",
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                Text(
                                  _cityName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      iconGetter(),
                      const SizedBox(height: 10),
                      weatherData_Handle_UI(),
                      const SizedBox(height: 100),
                      const Center(
                        child: Text(
                          "Weather Details Provided By OpenWeather",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Function to get weather icon and temperature/status details
  Row iconGetter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: Image.asset(
            getweatherIcon(_id),
            fit: BoxFit.fill,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 60, color: Colors.white),
            ),
            Text(
              _status,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ],
    );
  }

  // Function to display weather data in a grid format
  SizedBox weatherData_Handle_UI() {
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView(
          primary: false,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          shrinkWrap: true,
          children: [
            buildWeatherCard('Feels Like', '${_feelsLike.toStringAsFixed(1)}°C',
                'assets/feelslike.png'),
            buildWeatherCard('Humidity', '${_humidity.toString()}%',
                'assets/humidity.png'),
            buildWeatherCard('Pressure', '${_pressure.toString()}mBar',
                'assets/pressure.png'),
            buildWeatherCard('Wind Speed', '${_windspeed.toStringAsFixed(1)}kph',
                'assets/wind.png'),
          ],
        ),
      ),
    );
  }

  // Helper function to create weather data cards
  Widget buildWeatherCard(String title, String value, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Image.asset(
                  imagePath,
                  scale: 7,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}