import 'package:hive/hive.dart';
part 'company_model.g.dart';

@HiveType(typeId: 0)
class Restaurant extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String mobile;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final List<Employee> employees;

  @HiveField(6)
  final String companyId;

  Restaurant({
    required this.companyId,
    required this.name,
    required this.mobile,
    required this.category,
    required this.date,
    required this.address,
    required this.employees,
  });

  Restaurant copyWith(
      {String? name,
      String? mobile,
      String? category,
      String? date,
      String? address,
      List<Employee>? employees,
      String? companyId}) {
    return Restaurant(
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      category: category ?? this.category,
      date: date ?? this.date,
      address: address ?? this.address,
      employees: employees ?? List.from(this.employees),
    );
  }
}

@HiveType(typeId: 1)
class Employee {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String position;

  @HiveField(2)
  final List<UniformItemConfig> uniformConfig;

  @HiveField(3)
  final String gender; // 'Male' or 'Female'

  @HiveField(4)
  final String feedBack; // 'Male' or 'Female'

  Employee({
    required this.feedBack,
    required this.name,
    required this.position,
    required this.uniformConfig,
    required this.gender,
  });
}

@HiveType(typeId: 2)
class UniformItemConfig {
  @HiveField(0)
  final String itemName;

  @HiveField(1)
  final bool isNeeded;

  @HiveField(2)
  final bool isReadyMade;

  @HiveField(3)
  final String? selectedSize;

  @HiveField(4)
  final Map<String, String> measurements;

  @HiveField(5)
  final String? sleeveType; // 'Half Sleeve' or 'Full Sleeve'

  @HiveField(6)
  final String? tshirtStyle; // 'Polo' or 'Regular'

  @HiveField(7)
  final String? materialType; // Material type for all items

  @HiveField(8)
  final String? capStyle; // 'Cap' or 'Net'

  UniformItemConfig({
    required this.itemName,
    required this.isNeeded,
    required this.isReadyMade,
    this.selectedSize,
    required this.measurements,
    this.sleeveType,
    this.tshirtStyle,
    this.materialType,
    this.capStyle,
  });
}

class PositionData {
  static final Map<String, List<WorkerPosition>> positionsByCategory = {
    'Restaurant': [
      WorkerPosition(
        title: 'Executive Chef / Head Chef',
        items: {
          'Male': [
            UniformItem(name: 'Chef Coat'),
            UniformItem(name: 'Chef Hat or Cap'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Chef Pants'),
          ],
          'Female': [
            UniformItem(name: 'Chef Coat'),
            UniformItem(name: 'Chef Hat or Cap'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Chef Skirt/Pants'),
          ],
        },
      ),
      WorkerPosition(
        title: 'Sous Chef',
        items: {
          'Male': [
            UniformItem(name: 'Chef Coat'),
            UniformItem(name: 'Skull Cap or Chef Hat'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Chef Pants'),
          ],
          'Female': [
            UniformItem(name: 'Chef Coat'),
            UniformItem(name: 'Skull Cap or Chef Hat'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Chef Skirt/Pants'),
          ],
        },
      ),
      WorkerPosition(
        title: 'Line Cook / Commis Chef',
        items: {
          'Male': [
            UniformItem(name: 'Short-sleeved Chef Jacket'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Skull Cap or Bandana'),
            UniformItem(name: 'Chef Pants'),
          ],
          'Female': [
            UniformItem(name: 'Short-sleeved Chef Jacket'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Skull Cap or Bandana'),
            UniformItem(name: 'Chef Skirt/Pants'),
          ],
        },
      ),
      WorkerPosition(
        title: 'Pastry Chef',
        items: {
          'Male': [
            UniformItem(name: 'Chef Coat'),
            UniformItem(name: "Baker's Hat or Cap"),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Chef Pants'),
          ],
          'Female': [
            UniformItem(name: 'Chef Coat'),
            UniformItem(name: "Baker's Hat or Cap"),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Chef Skirt/Pants'),
          ],
        },
      ),
      WorkerPosition(
        title: 'Kitchen Helper / Steward',
        items: {
          'Male': [
            UniformItem(name: 'T-shirt or Kitchen Coat'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Cap or Hairnet'),
          ],
          'Female': [
            UniformItem(name: 'T-shirt or Kitchen Coat'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Cap or Hairnet'),
          ],
        },
      ),
    ],
    'Hotel': [
      WorkerPosition(
        title: 'Receptionist',
        items: {
          'Male': [
            UniformItem(name: 'Formal Shirt'),
            UniformItem(name: 'Blazer'),
            UniformItem(name: 'Formal Pants'),
            UniformItem(name: 'Name Tag'),
          ],
          'Female': [
            UniformItem(name: 'Formal Blouse'),
            UniformItem(name: 'Blazer'),
            UniformItem(name: 'Formal Skirt/Pants'),
            UniformItem(name: 'Name Tag'),
          ],
        },
      ),
      WorkerPosition(
        title: 'Housekeeping',
        items: {
          'Male': [
            UniformItem(name: 'Maid Uniform'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Gloves'),
          ],
          'Female': [
            UniformItem(name: 'Maid Uniform'),
            UniformItem(name: 'Apron'),
            UniformItem(name: 'Gloves'),
          ],
        },
      ),
    ],
    'Hospital': [
      WorkerPosition(
        title: 'Doctor',
        items: {
          'Male': [
            UniformItem(name: 'Lab Coat'),
            UniformItem(name: 'Scrubs'),
            UniformItem(name: 'Stethoscope'),
          ],
          'Female': [
            UniformItem(name: 'Lab Coat'),
            UniformItem(name: 'Scrubs'),
            UniformItem(name: 'Stethoscope'),
          ],
        },
      ),
      WorkerPosition(
        title: 'Nurse',
        items: {
          'Male': [
            UniformItem(name: 'Nursing Uniform'),
            UniformItem(name: 'Nursing Cap'),
            UniformItem(name: 'Watch'),
          ],
          'Female': [
            UniformItem(name: 'Nursing Uniform'),
            UniformItem(name: 'Nursing Cap'),
            UniformItem(name: 'Watch'),
          ],
        },
      ),
    ],
    'School': [
      WorkerPosition(
        title: 'Teacher',
        items: {
          'Male': [
            UniformItem(name: 'Formal Shirt'),
            UniformItem(name: 'Formal Pants'),
            UniformItem(name: 'Blazer (Optional)'),
          ],
          'Female': [
            UniformItem(name: 'Formal Blouse'),
            UniformItem(name: 'Formal Skirt/Pants'),
            UniformItem(name: 'Blazer (Optional)'),
          ],
        },
      ),
      WorkerPosition(
        title: 'Administrative Staff',
        items: {
          'Male': [
            UniformItem(name: 'Formal Shirt'),
            UniformItem(name: 'Formal Pants'),
            UniformItem(name: 'Name Tag'),
          ],
          'Female': [
            UniformItem(name: 'Formal Blouse'),
            UniformItem(name: 'Formal Skirt/Pants'),
            UniformItem(name: 'Name Tag'),
          ],
        },
      ),
    ],
    'Office': [
      WorkerPosition(
        title: 'Manager',
        items: {
          'Male': [
            UniformItem(name: 'Formal Shirt'),
            UniformItem(name: 'Suit Jacket'),
            UniformItem(name: 'Formal Pants'),
            UniformItem(name: 'Tie'),
          ],
          'Female': [
            UniformItem(name: 'Formal Blouse'),
            UniformItem(name: 'Suit Jacket'),
            UniformItem(name: 'Formal Skirt/Pants'),
            UniformItem(name: 'Scarf/Neckpiece'),
          ],
        },
      ),
      WorkerPosition(
        title: 'IT Staff',
        items: {
          'Male': [
            UniformItem(name: 'Company Polo Shirt'),
            UniformItem(name: 'Casual Pants'),
          ],
          'Female': [
            UniformItem(name: 'Company Polo Shirt'),
            UniformItem(name: 'Casual Skirt/Pants'),
          ],
        },
      ),
    ],
  };
}

class UniformItem {
  final String name;
  bool isNeeded;
  bool isReadyMade;
  String? selectedSize;
  Map<String, String> measurements;
  String? sleeveType;
  String? tshirtStyle;
  String? materialType;
  String? capStyle;

  UniformItem({
    required this.name,
    this.isNeeded = false,
    this.isReadyMade = true,
    this.selectedSize,
    Map<String, String>? measurements,
    this.sleeveType,
    this.tshirtStyle,
    this.materialType,
    this.capStyle,
  }) : measurements = measurements ?? {};
}

class WorkerPosition {
  final String title;
  final Map<String, List<UniformItem>> uniformItemsByGender;

  WorkerPosition({
    required this.title,
    required Map<String, List<UniformItem>> items,
  }) : uniformItemsByGender = items;

  List<UniformItem> getUniformItems(String gender) {
    return uniformItemsByGender[gender] ?? uniformItemsByGender['Male']!;
  }
}
