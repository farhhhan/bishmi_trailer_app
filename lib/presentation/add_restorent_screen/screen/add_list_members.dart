import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:bishmi_app/presentation/add_restorent_screen/screen/add_employee.dart';
import 'package:bishmi_app/presentation/home_screen/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'employee_detials.dart';

class EmployeeListScreen extends StatefulWidget {
  final Restaurant restaurant;
  final bool
      isEditing; // Flag to determine if we're editing an existing restaurant

  const EmployeeListScreen({
    required this.restaurant,
    this.isEditing = false,
    Key? key,
  }) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late Restaurant _workingRestaurant; // Local copy for editing

  @override
  void initState() {
    super.initState();
    // Create a working copy of the restaurant
    _workingRestaurant = widget.restaurant.copyWith();
  }

  void _navigateToAddEmployee({Employee? employee}) async {
    final newEmployee = await Navigator.push<Employee>(
      context,
      MaterialPageRoute(
        builder: (_) => AddWorkerPositionScreen(
          category: _workingRestaurant.category,
          name: _workingRestaurant.name,
          employee: employee,
        ),
      ),
    );

    if (newEmployee != null) {
      setState(() {
        if (employee != null) {
          // Update existing employee
          final index = _workingRestaurant.employees.indexOf(employee);
          _workingRestaurant.employees[index] = newEmployee;
        } else {
          // Add new employee
          _workingRestaurant.employees.add(newEmployee);
        }
      });
    }
  }

Future<void> _saveOrUpdateRestaurant() async {
  final box = Hive.box<Restaurant>('restaurants');
  final existingKeys = box.keys.cast<String>();
   print("${widget.restaurant.companyId} mmmmmmmmmmmmmm??????????????????????????????");
  if (widget.isEditing) {
    if (existingKeys.contains(_workingRestaurant.companyId)) {
      // ✅ Update existing restaurant
      await box.put(_workingRestaurant.companyId, _workingRestaurant);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_workingRestaurant.name} updated successfully')),
      );
    } else {
      // ⚠️ If companyId not found, fallback or show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Restaurant not found for editing.')),
      );
      return;
    }
  } else {
    // ✅ Add new restaurant if companyId is not used yet
    if (existingKeys.contains(_workingRestaurant.companyId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A restaurant with this ID already exists.')),
      );
      return;
    }

    await box.put(_workingRestaurant.companyId, _workingRestaurant);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_workingRestaurant.name} saved successfully')),
    );
  }

  // ✅ Navigate after success
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Employees" : "Add Employees"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B623),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _navigateToAddEmployee,
              child: const Text(
                "Add Workers",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              separatorBuilder: (context, index) => const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              itemCount: _workingRestaurant.employees.length,
              itemBuilder: (_, index) {
                final emp = _workingRestaurant.employees[index];
                return Dismissible(
                  key: Key('${emp.name}_${emp.position}_$index'),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _navigateToAddEmployee(employee: emp);
                      return false;
                    } else {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: Text("Delete ${emp.name}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      setState(() {
                        _workingRestaurant.employees.remove(emp);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${emp.name} deleted")),
                      );
                    }
                  },
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EmployeeDetailsScreen(employee: emp),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors
                          .primaries[index % Colors.primaries.length].shade100,
                      child: Center(
                        child: Text("${index + 1}"),
                      ),
                    ),
                    title: Text(emp.name),
                    subtitle: Text(emp.position),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 300,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0B623),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveOrUpdateRestaurant,
          child: Text(
            widget.isEditing ? "Update" : "Save",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
