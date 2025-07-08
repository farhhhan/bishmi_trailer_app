import 'dart:io';

import 'package:bishmi_app/firebase_options.dart';
import 'package:bishmi_app/presentation/add_cate/add_category.dart';
import 'package:bishmi_app/presentation/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';

import 'core/hive_model/company_model.dart';
import 'presentation/add_cate/add_cate_sc.dart';

void main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RestaurantAdapter());
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(UniformItemConfigAdapter());

  await Hive.openBox<Restaurant>('restaurants');
  await Hive.openBox('pdfs');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // final file = File('C:/Users/HP/Desktop/new/bishmi-2382d4981b96.json');
  // print(await file.exists()); // Should print true if the file is there
  // print(await file.readAsString()); // Should print the file contents


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => FirebaseService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}