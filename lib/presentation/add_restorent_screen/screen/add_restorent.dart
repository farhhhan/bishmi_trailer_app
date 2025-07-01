import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_list_members.dart';

class AddNewCustomerScreen extends StatefulWidget {
  final Restaurant? restaurant; // Null means adding new, non-null means editing
  bool isEdit;
  AddNewCustomerScreen({this.restaurant, Key? key, required this.isEdit})
      : super(key: key);

  @override
  _AddNewCustomerScreenState createState() => _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState extends State<AddNewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? selectedCategory;
  DateTime? selectedDate;
  List<String> categories = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    // If editing an existing restaurant, populate the fields
    if (widget.restaurant != null) {
      _restaurantController.text = widget.restaurant!.name;
      _mobileController.text = widget.restaurant!.mobile;
      _addressController.text = widget.restaurant!.address ?? '';
      _dateController.text = widget.restaurant!.date;
      selectedCategory = widget.restaurant!.category;

      // Parse the existing date
      try {
        final parts = widget.restaurant!.date.split('/');
        selectedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        selectedDate = DateTime.now();
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .get();
      
      setState(() {
        categories = snapshot.docs.map((doc) => doc.id).toList();
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF0B623),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _handleNextOrSave() {
    if (_formKey.currentState!.validate()) {
      final restaurant = widget.restaurant != null
          ? widget.restaurant!.copyWith(
              date: _dateController.text,
              name: _restaurantController.text,
              mobile: _mobileController.text,
              category: selectedCategory!,
              address: _addressController.text,
              companyId: widget.restaurant!.companyId)
          : Restaurant(
              companyId: DateTime.now().millisecondsSinceEpoch.toString(),
              date: _dateController.text,
              name: _restaurantController.text,
              mobile: _mobileController.text,
              category: selectedCategory!,
              employees: [],
              address: _addressController.text,
            );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeListScreen(
            restaurant: restaurant,
            isEditing: widget.isEdit,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.restaurant != null ? "Edit Customer" : "Add New Customer",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            const SizedBox(height: 20),

            // Customer Name
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Customer Name"),
            ),
            _buildTextField("Enter Customer Name", _restaurantController),
            const SizedBox(height: 20),

            // Mobile Number
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Mobile Number"),
            ),
            _buildTextField("Enter Mobile Number", _mobileController,
                inputType: TextInputType.phone),
            const SizedBox(height: 20),

            // Address
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Customer Address"),
            ),
            _buildTextField("Enter Address", _addressController),
            const SizedBox(height: 20),

            // Date Picker
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Scheduled Delivery Date"),
            ),
            const SizedBox(height: 10),
            _buildDatePickerField(context),
            const SizedBox(height: 20),

            // Category
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Choose Category"),
            ),
            const SizedBox(height: 10),
            _buildCategoryDropdown(),
            const SizedBox(height: 60),
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
            elevation: 4,
          ),
          onPressed: _handleNextOrSave,
          child: Text(
            widget.restaurant != null ? "Save Changes" : "Next",
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

  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: IgnorePointer(
        child: TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            hintText: "Select date",
            hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 184, 180, 180)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.calendar_today, color: Color(0xFFF0B623)),
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select a date' : null,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(width: 8),
            CircularProgressIndicator(color: Color(0xFFF0B623)),
            SizedBox(width: 16),
            Text('Loading categories...'),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No categories available'),
      );
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFF0B623)),
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }
}