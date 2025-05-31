import 'package:bishmi_app/presentation/auth_screen/login_screen/login_screen.dart';
import 'package:bishmi_app/presentation/home_screen/screen/home_screen.dart';
import 'package:flutter/material.dart';

import '../../constant/images/constant_images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSplashScreen();
  }

  Future<void> _initializeSplashScreen() async {
    await Future.delayed(
        Duration(seconds: 3)); // Minimum splash screen display time
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child:
              Image.asset(width: 400, height: 150, ConstantImages.bishmi_logo)),
    );
  }
}
