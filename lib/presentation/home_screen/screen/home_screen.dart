import 'dart:async';

import 'package:bishmi_app/constant/images/constant_images.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../widget/custom_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String greeting;
  late String saudiTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize timezone database
    _updateGreeting(); // Initial update

    // Update every 5 minutes (300,000 milliseconds)
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _updateGreeting();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  void _updateGreeting() {
    // Get current time in Saudi Arabia (Asia/Riyadh)
    final saudiTimeObj = tz.TZDateTime.now(tz.getLocation('Asia/Riyadh'));
    final hour = saudiTimeObj.hour;

    // Determine greeting based on Saudi time
    String newGreeting;
    if (hour >= 4 && hour < 12) {
      newGreeting = 'صَبَاحُ الْخَيْرِ'; // Good Morning
    } else if (hour >= 12 && hour < 17) {
      newGreeting = 'مَسَاءُ الْخَيْرِ'; // Good Afternoon
    } else {
      newGreeting = 'مَسَاءُ الْخَيْرِ'; // Good Evening
    }

    // Format time as h:mm AM/PM
    final formattedTime = DateFormat('h:mm a').format(saudiTimeObj);

    if (mounted) {
      setState(() {
        greeting = newGreeting;
        saudiTime = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                const CircleAvatar(
                  maxRadius: 30,
                  backgroundImage: NetworkImage(
                    'https://th.bing.com/th/id/OIP.IGNf7GuQaCqz_RPq5wCkPgHaLH?rs=1&pid=ImgDetMain',
                  ),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting ?? '...', // Handle initial null
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      saudiTime ?? '...',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomImageView(
                    fit: BoxFit.contain,
                    radius: BorderRadius.circular(12),
                    imagePath: ConstantImages.customAdd,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Add new Customer or Restaurant",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color.fromARGB(255, 231, 167, 71)),
                    child: const Center(
                      child: Text(
                        "Add New",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomImageView(
                          fit: BoxFit.contain,
                          radius: BorderRadius.circular(12),
                          imagePath: ConstantImages.listSvg,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Saved List",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(  
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 231, 167, 71)),
                          child: const Center(
                            child: Text(
                              "Show",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomImageView(
                          fit: BoxFit.contain,
                          radius: BorderRadius.circular(12),
                          imagePath: ConstantImages.reportSvg,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Report",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 231, 167, 71)),
                          child: const Center(
                            child: Text(
                              "Show",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
