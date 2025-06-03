import 'package:bishmi_app/constant/images/constant_images.dart';
import 'package:bishmi_app/core/firebase_model/user_model.dart';
import 'package:bishmi_app/presentation/auth_screen/login_screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignupScreen1 extends StatefulWidget {
  const SignupScreen1({super.key});

  @override
  State<SignupScreen1> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid
    }
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          employeeId: _employeeIdController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          
        );

        try {
          print('Attempting to write to Firestore for user: ${newUser.uid}');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(newUser.uid)
              .set(newUser.toJson());
          print('Firestore write successful for user: ${newUser.uid}');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully. Please login.')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()), 
            );
          }
        } on FirebaseException catch (e) {
            print('Firestore error during write: ${e.toString()}');
            if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Firestore error: ${e.message ?? e.code}')),
                );
            }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User creation failed (user null). Please try again.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Signup failed (Auth)';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your connection.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Unexpected error: ${e.toString()}');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
          );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      ConstantImages.bishmi_logo,
                      width: 400,
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color.fromARGB(255, 33, 146, 161),
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Create your account',
                            style: TextStyle(
                              color: Color.fromARGB(255, 33, 146, 161),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _employeeIdController,
                      decoration: InputDecoration(
                        labelText: 'Employee ID',
                        hintText: 'Enter your employee ID',
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter employee ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 4, 16, 82),
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 146, 161),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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