import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:bishmi_app/presentation/add_restorent_screen/screen/add_employee.dart';
import 'package:bishmi_app/presentation/home_screen/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'employee_detials.dart';

class EmployeeListScreen extends StatefulWidget {
  final Restaurant restaurant;

  const EmployeeListScreen({required this.restaurant, Key? key})
      : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  void _navigateToAddEmployee({Employee? employee}) async {
    final newEmployee = await Navigator.push<Employee>(
      context,
      MaterialPageRoute(
        builder: (_) => AddWorkerPositionScreen(
          category: widget.restaurant.category,
          name: widget.restaurant.name,
          employee: employee, // Pass existing employee for editing
        ),
      ),
    );

    if (newEmployee != null) {
      setState(() {
        if (employee != null) {
          // Update existing employee
          final index = widget.restaurant.employees.indexOf(employee);
          widget.restaurant.employees[index] = newEmployee;
        } else {
          // Add new employee
          widget.restaurant.employees.add(newEmployee);
        }
      });
    }
  }

  final List<Color> avatarColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];

  void _saveToHive() async {
    final box = Hive.box<Restaurant>('restaurants');
    await box.add(widget.restaurant);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.restaurant.name} saved successfully')),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => HomeScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Categories"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
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
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 10),
              separatorBuilder: (context, index) => Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              itemCount: widget.restaurant.employees.length,
              itemBuilder: (_, index) {
                final emp = widget.restaurant.employees[index];
                return Dismissible(
                  key: Key(emp.name + emp.position), // Unique key for each item
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe right - edit action
                      _navigateToAddEmployee(employee: emp);
                      return false; // Don't dismiss the item
                    } else {
                      // Swipe left - delete action
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text("Delete ${emp.name}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      // Swipe left confirmed - delete employee
                      setState(() {
                        widget.restaurant.employees.remove(emp);
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
                      backgroundColor:
                          avatarColors[index % avatarColors.length],
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
          onPressed: _saveToHive,
          child: const Text(
            "Save",
            style: TextStyle(
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
