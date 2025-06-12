import 'package:bishmi_app/presentation/auth_screen/signup_screen.dart/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/images/constant_images.dart';
import '../../home_screen/screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _emailController.removeListener(_checkFields);
    _passwordController.removeListener(_checkFields);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _areFieldsFilled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _onLoginPressed() async {
    if (_formKey.currentState!.validate() && _areFieldsFilled) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is badly formatted.';
        } else if (e.code == 'network-request-failed') {
          errorMessage = 'Network error. Please check your connection.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
                Positioned(
            top: MediaQuery.of(context).size.height * 0.46,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.10,
            child: CustomEllipse(
              width: MediaQuery.of(context).size.width * 1.5,
              height: MediaQuery.of(context).size.height * 0.6,
              colors: const [
                Color.fromARGB(255, 26, 182, 187),
                Color.fromARGB(255, 25, 131, 163),
              ],
              x: MediaQuery.of(context).size.width * 0.5,
              y: MediaQuery.of(context).size.height * 0.5,
              shadowBlurRadius: 0.5,
              shadowOffset: const Offset(1, 1),
            ),
          ),
              SafeArea(
                child: SingleChildScrollView(
                  // Ensures content is scrollable
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        // Use a container to set a minimum height
                        height: screenHeight *
                            0.9, // Ensure it takes at least screen height
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //SizedBox(height: screenHeight * 0.05),
                            Image.asset(
                                width: screenWidth * 0.8,
                                height: screenHeight * 0.30,
                                ConstantImages.bishmi_logo,
                                fit: BoxFit.contain),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 23, 156, 161),
                                    ),
                                  ),
                                  Text('''Please login and 
continue''',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                        color: const Color.fromARGB(
                                            255, 79, 79, 79),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor:
                                  const Color.fromARGB(255, 26, 182, 187),
                              decoration: InputDecoration(
                                hintText: 'User Id',
                                labelText: 'User Id',
                                prefixIcon: const Icon(Icons.person_outline,
                                    color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 15.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 36, 107, 126),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 26, 182, 187),
                                      width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your User Id';
                                }
                                if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Please enter a valid email as User Id';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              cursorColor:
                                  const Color.fromARGB(255, 26, 182, 187),
                              decoration: InputDecoration(
                                hintText: 'Pass word',
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Colors.black),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 15.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                          255, 36, 107, 126),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 26, 182, 187),
                                      width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      color: Colors.blueAccent, fontSize: 14),
                                ),
                              ),
                            ),
                            const Spacer(), // Pushes content below to the bottom

                            // Login Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0), // Reduced vertical padding
                              child: ElevatedButton(
                                onPressed: _areFieldsFilled && !_isLoading
                                    ? _onLoginPressed
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _areFieldsFilled
                                      ? Colors.orangeAccent
                                      : const Color.fromARGB(255, 171, 139, 97)
                                          .withOpacity(0.5),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                  elevation: _areFieldsFilled ? 2 : 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 50,
                                        height: 24,
                                        child: LoadingAnimationWidget
                                            .horizontalRotatingDots(
                                          color: Colors.orange,
                                          size: 40,
                                        ))
                                    : Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _areFieldsFilled
                                              ? Colors.white
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            // "Don't have an account?" Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? ",
                                    style: TextStyle(
                                        color: Colors.black87, fontSize: 14)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => SignupScreen1()),
                                    );
                                  },
                                  child: const Text(
                                    'Connect',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 41, 89, 233),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20), // Bottom spacing
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

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