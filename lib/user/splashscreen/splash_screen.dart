import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants.dart';
import '../onboardingscreen/onboardingscreen.dart';

class SplashScreen extends StatefulWidget
{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{

  @override
  void initState()
  {
    checkconnectivity();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
      (
      body: Center
        (
        child:  Lottie.asset('assets/anim.json'),
      ),
    );
  }

  void checkconnectivity() async
  {
    var connectivityresult = await Connectivity().checkConnectivity();

    if(connectivityresult.contains(ConnectivityResult.mobile))
    {
      Timer(Duration(seconds: 3), () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnboardingScreen()
      )));
    }
    else if(connectivityresult.contains(ConnectivityResult.wifi))
    {
      Timer(Duration(seconds: 3), () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnboardingScreen()
      )));
    }
    else
    {
      shownetworkerrordialog();
    }
  }

  void shownetworkerrordialog() async
  {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kGrey,
          title: Row(children: [Icon(Icons.error),Text("\tNetwork Error")],),
          content: Text('Please check your internet connection.',style: TextStyle(fontStyle: FontStyle.italic)),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                exit(0);
              },
              child: Text("Exit",style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }
}