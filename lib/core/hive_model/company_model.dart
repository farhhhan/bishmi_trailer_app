import 'package:hive/hive.dart';
part  'company_model.g.dart';

@HiveType(typeId: 0)
class Restaurant extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String mobile;

  @HiveField(2)
  String category;

  @HiveField(3)
  List<Employee> employees;

  Restaurant({
    required this.name,
    required this.mobile,
    required this.category,
    required this.employees,
  });
}

@HiveType(typeId: 1)
class Employee extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String role;

  Employee({required this.name, required this.role});
}
