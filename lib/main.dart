import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectapi/screen/Weather_Screen.dart';

void main(){
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}
