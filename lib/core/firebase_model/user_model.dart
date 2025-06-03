

class UserModel {
  final String uid;
  final String employeeId;
  final String phoneNumber;
  final String username;
  final String email;
 // final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.employeeId,
    required this.phoneNumber,
    required this.username,
    required this.email,
   // required this.createdAt,
  });

  // Method to convert UserModel to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'employeeId': employeeId,
      'phoneNumber': phoneNumber,
      'username': username,
      'email': email,
     // 'createdAt': createdAt,
    };
  }

  // Factory constructor to create a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      employeeId: json['employeeId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      //createdAt: json['createdAt'] as Timestamp,
    );
  }
} 