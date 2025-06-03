

import 'package:bishmi_app/presentation/auth_screen/signup_screen.dart/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      _areFieldsFilled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
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
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
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
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
      finally {
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
            top: screenHeight * 0.45,
            left: 0,
            right: 0,
            child: CustomEllipse(
              width: screenWidth * 1.5,
              height: screenHeight * 0.6,
              colors: const [
                Color.fromARGB(255, 175, 222, 224),
                Color.fromARGB(255, 175, 222, 224),
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
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                      width: screenWidth * 0.5, height: screenHeight * 0.15, ConstantImages.bishmi_logo, fit: BoxFit.contain),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                              color: Color.fromARGB(255, 26, 182, 187),
                              fontSize: 28,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Please login and continue',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: const Color.fromARGB(255, 26, 182, 187),
                      decoration: InputDecoration(
                        hintText: 'User Id',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 26, 182, 187), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.red, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your User Id';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email as User Id';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    cursorColor: const Color.fromARGB(255, 26, 182, 187),
                    decoration: InputDecoration(
                      hintText: 'Pass word',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                           color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 26, 182, 187), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.red, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
                        // TODO: Implement Forgot Password
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20, top: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 175, 222, 224),
                 borderRadius: const BorderRadius.only(
                   topLeft: Radius.circular(30),
                   topRight: Radius.circular(30),
                 )
              ),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: _areFieldsFilled && !_isLoading ? _onLoginPressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _areFieldsFilled 
                          ? const Color.fromARGB(255, 224, 226, 213)
                          : const Color.fromARGB(255, 224, 226, 213).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: _areFieldsFilled ? 2 : 0, 
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 78, 161, 209))))
                        : Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              color: _areFieldsFilled 
                                ? const Color.fromARGB(255, 112, 112, 112)
                                : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.black87, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) =>  SignupScreen1()),
                        );
                      },
                      child: const Text(
                        'Connect',
                        style: TextStyle(color: Color.fromARGB(255, 26, 182, 187), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ]),
            ), 
           ),
        ],
      ),
    ));
  }
}

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
