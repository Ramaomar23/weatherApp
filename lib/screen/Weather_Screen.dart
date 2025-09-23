import 'package:flutter/material.dart';
import '../Services/Weather_Services.dart';
import '../Model/Weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();
  final WeatherService weatherService = WeatherService();

  String city = "Amman";
  String _result = "";
  late Future<Weather> weatherFuture;



  @override
  void initState() {
    super.initState();
    weatherFuture = weatherService.fetchWeather(city);
  }

  void _citySearch() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        city = _controller.text;
        weatherFuture = weatherService.fetchWeather(city);
        _result = "Searching for $city...";
      });
    }
  }

  void _toggleFavorite(String cityName, double temp) {
    setState(() {
      weatherService.toggleFavorite(cityName, temp);
    });
  }

  void saveNote(String cityName, String note) {
    setState(() {
      weatherService.patchNote(cityName, note);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFcaf0f8), Color(0xFF0077b6)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Weather",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
            //.............................Search for a city .......................................
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter City Name",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onSubmitted: (_) => _citySearch(),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(_result),

              Expanded(
                child: Center(
                  child: FutureBuilder<Weather>(
                    future: weatherFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData) {
                        return const Text("No data");
                      } else {
                        final weather = snapshot.data!;
                        final isfav =
                        weatherService.favoriteCities.containsKey(weather.city);

        //.....................................City Card..................................................

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              weather.city,
                                              style: const TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 5),
                                            IconButton(
                                              onPressed: () => _toggleFavorite(
                                                  weather.city,
                                                  weather.temperature.toDouble()),
                                              icon: Icon(
                                                isfav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isfav ? Colors.red : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Text("${weather.temperature.toStringAsFixed(1)}°C",
                                            style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "${weather.country} • ${weather.localtime}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Image.network(weather.icon,
                                            width: 70, height: 70),
                                        const SizedBox(height: 40),
                                        Text(weather.description,
                                            style:
                                            const TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17.0),
                                  child: const Text(
                                    "Favorite Cities:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                          //............................List Favorite City......................................
                              const SizedBox(height: 5),
                              for (var fav
                              in weatherService.favoriteCities.keys)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  //.......................Note......................................
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fav,
                                        style: const TextStyle(
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                          "${weatherService.favoriteTemperatures[fav]?.toStringAsFixed(1)}°C",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 9),
                                      Text(
                                          weatherService.cityNotes[fav] ??
                                              "No note yet",
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 20)),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _controllerNote.text =
                                                  weatherService.cityNotes[fav] ??
                                                      "";
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor: Colors.white,
                                                    title:
                                                    Text("Edit Note for $fav"),
                                                    content: TextField(
                                                        controller:
                                                        _controllerNote),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          saveNote(fav,
                                                              _controllerNote
                                                                  .text);
                                                          Navigator.pop(context);
                                                          showModalBottomSheet(
                                                              context: context, builder:(context){
                                                            return Container(
                                                                height: 50,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.grey,
                                                                    borderRadius: BorderRadius.only(
                                                                        topRight: Radius.circular(20),
                                                                        topLeft: Radius.circular(20),

                                                          ),),
                                                                 child: Center(
                                                                 child: Text(
                                                                 "Your note has been added: ${_controllerNote.text}",
                                                                 textAlign: TextAlign.center,
                                                               ),
                                                               ),
                                                              );
                                                             },
                                                            );
                                                          },
                                                        child:
                                                        const Text("Save"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                weatherService.favoriteCities
                                                    .remove(fav);
                                                weatherService.cityNotes.remove(fav);
                                                weatherService
                                                    .favoriteTemperatures
                                                  .remove(fav);
                                            });
                                          },
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        );
                      }
                    },
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
