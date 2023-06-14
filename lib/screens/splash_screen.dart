import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/screens/home_screen.dart';

import '../../main.dart';
import 'dart:async';

import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SplashScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Timer _timer = new Timer(const Duration(milliseconds: 2000), () {
      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.white));
      if (APIs.auth.currentUser != null) {
        // log('\nUser: ${FirebaseAuth.instance.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        //navigate to home
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Initialising mediaquery for getting device screen size
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .3,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('images/icon.png')),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              // left: mq.width * .30,
              child: Text(
                'MADE IN INDIA WITH ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ))
        ],
      ),
    );
  }
}
