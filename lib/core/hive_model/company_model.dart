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
  final List<Employee> employees;

  Restaurant({
    required this.name,
    required this.mobile,
    required this.category,
    required this.employees,
  });
}

@HiveType(typeId: 1)
class Employee {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String position;

  @HiveField(2)
  final List<UniformItemConfig> uniformConfig;

  Employee({
    required this.name,
    required this.position,
    required this.uniformConfig,
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

  // New fields for additional options
  @HiveField(5)
  final String? sleeveType;      // 'Half Sleeve' or 'Full Sleeve'

  @HiveField(6)
  final String? tshirtStyle;     // 'Polo' or 'Regular'

  @HiveField(7)
  final String? materialType;    // Material type for all items

  @HiveField(8)
  final String? capStyle;        // 'Cap' or 'Net'

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

// Category-based position definitions
class PositionData {
  static final Map<String, List<WorkerPosition>> positionsByCategory = {
    'Restaurant': [
      WorkerPosition(
        title: 'Executive Chef / Head Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: 'Chef Hat or Cap'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Sous Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: 'Skull Cap or Chef Hat'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Line Cook / Commis Chef',
        uniformItems: [
          UniformItem(name: 'Short-sleeved Chef Jacket'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Skull Cap or Bandana'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Pastry Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: "Baker's Hat or Cap"),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Kitchen Helper / Steward',
        uniformItems: [
          UniformItem(name: 'T-shirt or Kitchen Coat'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Cap or Hairnet'),
        ],
      ),
    ],
    'Hotel': [
      WorkerPosition(
        title: 'Receptionist',
        uniformItems: [
          UniformItem(name: 'Formal Shirt'),
          UniformItem(name: 'Blazer'),
          UniformItem(name: 'Formal Pants'),
          UniformItem(name: 'Name Tag'),
        ],
      ),
      WorkerPosition(
        title: 'Housekeeping',
        uniformItems: [
          UniformItem(name: 'Maid Uniform'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Gloves'),
        ],
      ),
      // Add more hotel positions as needed
    ],
    'Hospital': [
      WorkerPosition(
        title: 'Doctor',
        uniformItems: [
          UniformItem(name: 'Lab Coat'),
          UniformItem(name: 'Scrubs'),
          UniformItem(name: 'Stethoscope'),
        ],
      ),
      WorkerPosition(
        title: 'Nurse',
        uniformItems: [
          UniformItem(name: 'Nursing Uniform'),
          UniformItem(name: 'Nursing Cap'),
          UniformItem(name: 'Watch'),
        ],
      ),
      // Add more hospital positions as needed
    ],
    'School': [
      WorkerPosition(
        title: 'Teacher',
        uniformItems: [
          UniformItem(name: 'Formal Shirt'),
          UniformItem(name: 'Formal Pants/Skirt'),
          UniformItem(name: 'Blazer (Optional)'),
        ],
      ),
      WorkerPosition(
        title: 'Administrative Staff',
        uniformItems: [
          UniformItem(name: 'Formal Shirt'),
          UniformItem(name: 'Formal Pants'),
          UniformItem(name: 'Name Tag'),
        ],
      ),
      // Add more school positions as needed
    ],
    'Office': [
      WorkerPosition(
        title: 'Manager',
        uniformItems: [
          UniformItem(name: 'Formal Shirt'),
          UniformItem(name: 'Suit Jacket'),
          UniformItem(name: 'Formal Pants'),
          UniformItem(name: 'Tie'),
        ],
      ),
      WorkerPosition(
        title: 'IT Staff',
        uniformItems: [
          UniformItem(name: 'Company Polo Shirt'),
          UniformItem(name: 'Casual Pants'),
        ],
      ),
      // Add more office positions as needed
    ],
  };
}

// UI Models (non-Hive, for UI state management)
class UniformItem {
  final String name;
  bool isNeeded;
  bool isReadyMade;
  String? selectedSize;
  Map<String, String> measurements;
  String? sleeveType;      // 'Half Sleeve' or 'Full Sleeve'
  String? tshirtStyle;     // 'Polo' or 'Regular'
  String? materialType;    // Material type for all items
  String? capStyle;        // 'Cap' or 'Net'

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
  List<UniformItem> uniformItems;

  WorkerPosition({
    required this.title,
    required this.uniformItems,
  });
}