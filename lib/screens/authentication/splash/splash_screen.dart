import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network/core/core.dart';
import 'package:wicket_live_apk/screens/authentication/login/login_screen.dart';
import 'package:wicket_live_assets/wicketLive_assets.dart';

import '../../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SharedPreferenceHelper sharedPreferenceHelper = SharedPreferenceHelper(Preference());
  List<String> playersList = [
    'Karan',
    'Aman',
    'Ketan',
    'Kaushal',
    'Nikhil',
    'Rajat',
    'Nikunj',
    'Ajay',
    'Tarak',
    'Harshal',
    'Srinivas',
    'Keyur',
    'Nilesh',
    'Rikul',
    'Urvish',
    'Naimesh',
    'Parth',
    'Jay',
    'Mitul',
    'Hemal',
    'Nirmit',
    'Pankaj',
    'Sachin',
    'Jigar',
  ];
  void initState() {
    // TODO: implement initState
    super.initState();
    List<String> playerss = sharedPreferenceHelper.players ?? [];
    playerss.isEmpty ? sharedPreferenceHelper.savePlayers(playersList) : null;
    Future.delayed(const Duration(seconds: 3)).then(
          (value) => Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const DashboardScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WicketLiveAssets.lottie.splashLottie.lottie(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                repeat: false),
          ],
        ),
      ),
    );
  }
}
