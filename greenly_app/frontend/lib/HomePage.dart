import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.blueAccent,
                  Colors.greenAccent
                ])
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 100, horizontal: 50),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white54
              ),
            )
          ],
        ),
      ),
      

    );
  }
}
