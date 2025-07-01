// import 'package:flutter/material.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';

// class FirebaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Categories
//   Future<void> addCategory(String categoryName) async {
//     await _firestore.collection('categories').doc(categoryName).set(
//       FirebaseCategory(
//         name: categoryName,
//         createdAt: DateTime.now(),
//       ).toMap(),
//     );
//   }

//   Future<List<String>> getCategories() async {
//     final snapshot = await _firestore.collection('categories').get();
//     return snapshot.docs.map((doc) => doc.id).toList();
//   }

//   // Positions
//   Future<void> addPosition(String category, FirebasePosition position) async {
//     await _firestore
//         .collection('categories')
//         .doc(category)
//         .collection('positions')
//         .doc(position.title)
//         .set(position.toMap());
//   }

//   Future<List<FirebasePosition>> getPositionsByCategory(String category) async {
//     final snapshot = await _firestore
//         .collection('categories')
//         .doc(category)
//         .collection('positions')
//         .get();
//     return snapshot.docs
//         .map((doc) => FirebasePosition.fromMap(doc.data()))
//         .toList();
//   }

//   Future<void> deleteCategory(String categoryName) async {
//     await _firestore.collection('categories').doc(categoryName).delete();
//   }

//   Future<void> deletePosition(String category, String positionTitle) async {
//     await _firestore
//         .collection('categories')
//         .doc(category)
//         .collection('positions')
//         .doc(positionTitle)
//         .delete();
//   }
// }
// class FirebaseCategory {
//   final String name;
//   final DateTime createdAt;

//   FirebaseCategory({required this.name, required this.createdAt});

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }

//   factory FirebaseCategory.fromMap(Map<String, dynamic> map) {
//     return FirebaseCategory(
//       name: map['name'],
//       createdAt: DateTime.parse(map['createdAt']),
//     );
//   }
// }

// class FirebaseUniformItem {
//   final String name;
//   final bool isRequired;
//   final List<MeasurementField> measurementFields;

//   FirebaseUniformItem({
//     required this.name,
//     this.isRequired = true,
//     this.measurementFields = const [],
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'isRequired': isRequired,
//       'measurementFields': measurementFields.map((field) => field.toMap()).toList(),
//     };
//   }

//   factory FirebaseUniformItem.fromMap(Map<String, dynamic> map) {
//     return FirebaseUniformItem(
//       name: map['name'],
//       isRequired: map['isRequired'] ?? true,
//       measurementFields: List<MeasurementField>.from(
//         map['measurementFields']?.map((x) => MeasurementField.fromMap(x)) ?? [],
//       ),
//     );
//   }
// }

// class FirebasePosition {
//   final String title;
//   final Map<String, List<FirebaseUniformItem>> uniformItemsByGender;

//   FirebasePosition({
//     required this.title,
//     required this.uniformItemsByGender,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'uniformItemsByGender': uniformItemsByGender.map(
//         (key, value) => MapEntry(
//           key,
//           value.map((item) => item.toMap()).toList(),
//         ),
//       ),
//     };
//   }

//   factory FirebasePosition.fromMap(Map<String, dynamic> map) {
//     return FirebasePosition(
//       title: map['title'],
//       uniformItemsByGender: Map<String, List<FirebaseUniformItem>>.from(
//         map['uniformItemsByGender'].map(
//           (key, value) => MapEntry(
//             key,
//             List<FirebaseUniformItem>.from(
//                 value.map((x) => FirebaseUniformItem.fromMap(x))),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MeasurementField {
//   final String name;
//   final String unit;
//   final bool isRequired;

//   MeasurementField({
//     required this.name,
//     required this.unit,
//     this.isRequired = true,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'unit': unit,
//       'isRequired': isRequired,
//     };
//   }

//   factory MeasurementField.fromMap(Map<String, dynamic> map) {
//     return MeasurementField(
//       name: map['name'],
//       unit: map['unit'],
//       isRequired: map['isRequired'] ?? true,
//     );
//   }
// }