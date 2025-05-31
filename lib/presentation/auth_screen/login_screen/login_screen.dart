import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../constant/images/constant_images.dart';
import '../../home_screen/screen/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (email == 'bishmi@12' && password == '123456') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.45,
            left: 0,
            right: 0,
            child: CustomEllipse(
              width: screenWidth * 1.5,
              height: screenHeight * 0.6,
              colors: const [
                Color.fromARGB(255, 26, 182, 187),
                Color.fromARGB(255, 25, 131, 163),
              ],
              x: screenWidth * 0.5,
              y: screenHeight * 0.5,
              shadowBlurRadius: 0.5,
              shadowOffset: const Offset(1, 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                      width: 400, height: 150, ConstantImages.bishmi_logo),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                              color: Color.fromARGB(255, 33, 146, 161),
                              fontSize: 28,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Please login and continue',
                          style: TextStyle(
                              color: Color.fromARGB(255, 33, 146, 161),
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: const Color.fromARGB(255, 23, 152, 175),
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        hintText: 'Enter your username',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Background ellipse and other existing widgets remain the same

          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 35),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 25, left: 40, right: 40),
                  child: ElevatedButton(
                    onPressed: _onLoginPressed,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 4, 16, 82),
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 78, 161, 209),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CustomEllipse and _EllipsePainter classes remain unchanged
/// Draws an ellipse with a linear gradient fill and optional blurred shadow.
class CustomEllipse extends StatelessWidget {
  final double width;
  final double height;
  final List<Color> colors;
  final double x;
  final double y;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  const CustomEllipse({
    Key? key,
    required this.width,
    required this.height,
    required this.colors,
    required this.x,
    required this.y,
    this.shadowBlurRadius = 10.0,
    this.shadowOffset = const Offset(5.0, 5.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EllipsePainter(
          width: width,
          height: height,
          colors: colors,
          x: x,
          y: y,
          shadowBlurRadius: shadowBlurRadius,
          shadowOffset: shadowOffset,
        ),
      ),
    );
  }
}

class _EllipsePainter extends CustomPainter {
  final double width;
  final double height;
  final List<Color> colors;
  final double x;
  final double y;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  _EllipsePainter({
    required this.width,
    required this.height,
    required this.colors,
    required this.x,
    required this.y,
    required this.shadowBlurRadius,
    required this.shadowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + shadowOffset.dx, y + shadowOffset.dy),
        width: width,
        height: height,
      ),
      shadowPaint,
    );

    final ellipsePaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(
        Rect.fromCenter(
          center: Offset(x, y),
          width: width,
          height: height,
        ),
      )
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: width,
        height: height,
      ),
      ellipsePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
