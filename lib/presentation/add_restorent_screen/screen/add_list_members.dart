import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:bishmi_app/presentation/add_restorent_screen/screen/add_employee.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class EmployeeListScreen extends StatefulWidget {
  final Restaurant restaurant;

  const EmployeeListScreen({required this.restaurant, Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  void _navigateToAddEmployee() async {
    final newEmployee = await Navigator.push<Employee>(
      context,
      MaterialPageRoute(builder: (_) => AddEmployeeScreen()),
    );

    if (newEmployee != null) {
      setState(() {
        widget.restaurant.employees.add(newEmployee);
      });
    }
  }

  void _saveToHive() async {
    final box = Hive.box<Restaurant>('restaurants');
    await box.add(widget.restaurant);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employees")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.restaurant.employees.length,
              itemBuilder: (_, index) {
                final emp = widget.restaurant.employees[index];
                return ListTile(
                  title: Text(emp.name),
                  subtitle: Text(emp.role),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _navigateToAddEmployee,
                    child: Text("+ Add Employee"),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveToHive,
                  child: Text("Submit"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
