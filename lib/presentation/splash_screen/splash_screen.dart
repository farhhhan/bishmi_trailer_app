import 'package:bishmi_app/presentation/auth_screen/login_screen/login_screen.dart';
import 'package:bishmi_app/presentation/home_screen/screen/home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constant/images/constant_images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  )..repeat();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Transform.scale(
            scale: 0.8 + (_controller.value * 0.4),
            child: Image.asset(
              ConstantImages.bishmi_logo,
              width: 600,
              height: 300,
            ),
          ),
        ),
      ),
    );
  }
}
