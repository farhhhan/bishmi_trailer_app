import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:flutter/material.dart';

import 'add_list_members.dart';

class AddNewCustomerScreen extends StatefulWidget {
  @override
  _AddNewCustomerScreenState createState() => _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState extends State<AddNewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String? selectedCategory;

  final categories = ['Restaurant', 'School', 'Office', 'Hospital', 'Hotel'];

  @override
  void dispose() {
    _restaurantController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "Add New Customer",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            SizedBox(
              height: 20,
            ),
            const Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Restaurant Name",
                style: TextStyle(color: Colors.black),
              ),
            ),
            _buildTextField("Enter Restaurant Name", _restaurantController),
            const SizedBox(height: 20),
            const Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Mobile Number",
                style: TextStyle(color: Colors.black),
              ),
            ),
            _buildTextField("Enter Mobile Number", _mobileController,
                inputType: TextInputType.phone),
            const SizedBox(height: 20),
            const Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Choose Category",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            _buildCategoryDropdown(),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Submit or save data here
              final restaurant = Restaurant(
                name: _restaurantController.text,
                mobile: _mobileController.text,
                category: selectedCategory!,
                employees: [],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeListScreen(restaurant: restaurant),
                ),
              );
            }
          },
          child: const Text(
            "Next",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 184, 180, 180)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: categories
          .map((category) =>
              DropdownMenuItem(value: category, child: Text(category)))
          .toList(),
      value: selectedCategory,
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }
}
