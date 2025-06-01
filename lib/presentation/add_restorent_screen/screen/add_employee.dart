import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:flutter/material.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  void _save() {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        name: _nameController.text,
        role: _roleController.text,
      );
      Navigator.pop(context, employee);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Employee Name'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _roleController,
              decoration: InputDecoration(labelText: 'Employee Role'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text('Save Employee'),
            ),
          ]),
        ),
      ),
    );
  }
}
