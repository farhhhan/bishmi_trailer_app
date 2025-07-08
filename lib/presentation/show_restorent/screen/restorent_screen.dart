import 'package:bishmi_app/core/hive_model/company_model.dart';

import 'package:bishmi_app/core/pdf/pdf_generator.dart';
import 'package:bishmi_app/presentation/add_restorent_screen/screen/add_list_members.dart';

import 'package:bishmi_app/presentation/add_restorent_screen/screen/add_restorent.dart';
import 'package:bishmi_app/presentation/add_restorent_screen/screen/employee_detials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantListScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const RestaurantListScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  late Box<Restaurant> restaurantBox;
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  String filterOrder = 'none'; // 'asc', 'desc', or 'none'
  int numb = 0; // 'asc', 'desc', or 'none'

  @override
  void initState() {
    super.initState();
    restaurantBox = Hive.box<Restaurant>('restaurants');
  }

  String _getRemainingDaysText(String dateString) {
    try {
      // Parse using correct format: dd/MM/yyyy
      final format =
          DateFormat('d/M/yyyy'); // handles both 20/6/2025 and 05/06/2025
      final deadline = format.parse(dateString);
      final now = DateTime.now();
      final difference = deadline.difference(now).inDays;

      if (difference > 0) {
        return '$difference days ';
      } else if (difference == 0) {
        return '0 days(Today)';
      } else {
        return 'Deadline passed';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<int> getUniqueUniformItemNameCount(String restaurantId) async {
    final firestore = FirebaseFirestore.instance;
    final Set<String> uniqueItemNames = {};

    try {
      // 1. Get the restaurant document to determine the category
      final restaurantDoc =
          await firestore.collection('restaurants').doc(restaurantId).get();
      if (!restaurantDoc.exists) return 0;

      final category = restaurantDoc.data()?['category'] as String?;
      if (category == null) return 0;

      // 2. Get all employees for this restaurant
      final employeesSnapshot = await firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('employees')
          .get();

      // Track processed positions to avoid duplicates
      final Set<String> processedPositions = {};

      for (final employeeDoc in employeesSnapshot.docs) {
        final position = employeeDoc.data()['position'] as String?;
        final gender = employeeDoc.data()['gender'] as String?;

        if (position == null || gender == null) continue;
        if (processedPositions.contains(position)) continue;

        processedPositions.add(position);

        // 3. Get the position details from the category
        final positionDoc = await firestore
            .collection('categories')
            .doc(category)
            .collection('positions')
            .doc(position)
            .get();

        if (!positionDoc.exists) continue;

        // 4. Get uniform items for this position and gender
        final uniformItemsByGender = positionDoc.data()?['uniformItemsByGender']
            as Map<String, dynamic>?;
        if (uniformItemsByGender == null) continue;

        final itemsForGender = uniformItemsByGender[gender] as List<dynamic>?;
        if (itemsForGender == null) continue;

        // 5. Add all item names to the unique set
        for (final item in itemsForGender) {
          final itemName = item['name'] as String?;
          if (itemName != null) {
            uniqueItemNames.add(itemName.trim());
          }
        }
      }
      setState(() {
        numb = uniqueItemNames.length;
      });
      return uniqueItemNames.length;
    } catch (e) {
      print('Error getting unique uniform items count: $e');
      return 0;
    }
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> restaurants) {
    List<Restaurant> filtered = restaurants
        .where((r) =>
            r.name.toLowerCase().contains(searchText.toLowerCase().trim()))
        .toList();

    if (filterOrder == 'asc') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (filterOrder == 'desc') {
      filtered.sort((a, b) => b.name.compareTo(a.name));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Lists',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Field
          // Search Field + Filter Icon
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => searchText = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by restaurant name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Filter Icon with PopupMenu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      filterOrder = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    CheckedPopupMenuItem(
                      value: 'asc',
                      checked: filterOrder == 'asc',
                      child: const Text('A-Z (Ascending)'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'desc',
                      checked: filterOrder == 'desc',
                      child: const Text('Z-A (Descending)'),
                    ),
                    if (filterOrder != 'none') const PopupMenuDivider(),
                    if (filterOrder != 'none')
                      PopupMenuItem(
                        value: 'none',
                        child: const Text('Clear Filter'),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // List of Restaurants
          Expanded(
            child: ValueListenableBuilder<Box<Restaurant>>(
              valueListenable: restaurantBox.listenable(),
              builder: (context, box, _) {
                final allRestaurants = box.values.toList().cast<Restaurant>();
                final filteredRestaurants = _filterRestaurants(allRestaurants);

                if (filteredRestaurants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 20),
                        const Text(
                          'No Restaurants Yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _navigateToAddRestaurant(),
                          child: const Text('Add Your First Restaurant'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = filteredRestaurants[index];
                    getUniqueUniformItemNameCount(restaurant.companyId);

                    return Dismissible(
                      key: Key(restaurant.name + restaurant.category),
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
                          _navigateToEditRestaurant(restaurant);
                          return false;
                        } else {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: Text("Delete ${restaurant.name}?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          restaurant.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("${restaurant.name} deleted")),
                          );
                        }
                      },
                      child: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
  child: InkWell(
    onTap: () => _showRestaurantDetails(restaurant),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Name + Category
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: const Icon(Icons.restaurant, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        restaurant.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showRestaurantDetails(restaurant),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom Row: Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(
                  //icon: Icons.people_outline_sharp,
                  label: '${restaurant.employees.length}',
                  iconData:Icons.people_outline_sharp,

                ),
                _InfoItem(
                  iconData: FontAwesomeIcons.shirt,
                  label: '$numb',
                  iconSize: 15,
                ),
                _InfoItem(
                  iconData: FontAwesomeIcons.clock,
                  label: _getRemainingDaysText(restaurant.date),
                  iconSize: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
),

                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddRestaurant() {
    // Implement navigation to your add restaurant screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRestaurantScreen()));
  }

  void _navigateToEditRestaurant(Restaurant restaurant) {
    // Implement navigation to your edit restaurant screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddNewCustomerScreen(
                  restaurant: restaurant,
                  isEdit: true,
                )));
  }

  void _showRestaurantDetails(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RestaurantDetailsBottomSheet(restaurant: restaurant);
      },
    );
  }
}

class _RestaurantDetailsBottomSheet extends StatefulWidget {
  final Restaurant restaurant;

  const _RestaurantDetailsBottomSheet({required this.restaurant});

  @override
  State<_RestaurantDetailsBottomSheet> createState() =>
      _RestaurantDetailsBottomSheetState();
}

class _RestaurantDetailsBottomSheetState
    extends State<_RestaurantDetailsBottomSheet> {
  // Filter variables
  String searchQuery = '';
  String genderFilter = 'All';
  String typeFilter = 'All';
  String sortOrder = 'A-Z';

  final TextEditingController _searchController = TextEditingController();

  // Function to get filtered and sorted employees
  List<Employee> getFilteredEmployees() {
    List<Employee> filtered = widget.restaurant.employees.where((employee) {
      bool matchesSearch = searchQuery.isEmpty ||
          employee.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          employee.position.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesGender =
          genderFilter == 'All' || employee.gender == genderFilter;
      bool matchesType = typeFilter == 'All' || employee.position == typeFilter;
      return matchesSearch && matchesGender && matchesType;
    }).toList();

    // Sort employees
    if (sortOrder == 'A-Z') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else {
      filtered.sort((a, b) => b.name.compareTo(a.name));
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Employee> filteredEmployees = getFilteredEmployees();

    return Container(

      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        //  gradient: LinearGradient(
        //        // colors: [Colors.blue.shade50, Colors.indigo.shade50],
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //       ),
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Enhanced Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //  // colors: [Colors.blue.shade50, Colors.indigo.shade50],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant name and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurant.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${widget.restaurant.employees.length} Team Members',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // // Enhanced Stats Cards
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildModernStatCard(
                //         icon: Icons.groups_rounded,
                //         count: filteredEmployees.length.toString(),
                //         label: searchQuery.isNotEmpty ||
                //                 genderFilter != 'All' ||
                //                 typeFilter != 'All'
                //             ? 'Found'
                //             : 'Total',
                //         color: Colors.blue,
                //         gradient: [Colors.blue.shade400, Colors.blue.shade600],
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildModernStatCard(
                //         icon: Icons.man_rounded,
                //         count: filteredEmployees
                //             .where((e) => e.gender == 'Male')
                //             .length
                //             .toString(),
                //         label: 'Male',
                //         color: Colors.green,
                //         gradient: [Colors.green.shade400, Colors.green.shade600],
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildModernStatCard(
                //         icon: Icons.woman_rounded,
                //         count: filteredEmployees
                //             .where((e) => e.gender == 'Female')
                //             .length
                //             .toString(),
                //         label: 'Female',
                //         color: Colors.pink,
                //         gradient: [Colors.pink.shade400, Colors.pink.shade600],
                //       ),
                //     ),
                //   ],
                // ),

               // const SizedBox(height: 24),

                // Modern Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Modern Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildModernFilterChip(
                        'Gender',
                        genderFilter,
                        ['All', 'Male', 'Female'],
                        (value) => setState(() => genderFilter = value),
                        Icons.people_outline_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildModernFilterChip(
                        'Sort',
                        sortOrder,
                        ['A-Z', 'Z-A'],
                        (value) => setState(() => sortOrder = value),
                        Icons.sort_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Employee List with Modern Design
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: filteredEmployees.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      key: ValueKey(filteredEmployees.length),
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      itemCount: filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = filteredEmployees[index];
                        return _buildModernEmployeeCard(employee, index);
                      },
                    ),
            ),
          ),

          // Modern Action Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildModernActionButton(
                    icon: Icons.preview_rounded,
                    label: 'Preview PDF',
                    gradient: [Colors.blue.shade500, Colors.blue.shade700],
                    onPressed: () async {
                      // Retrieve the current user's email from SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      final currentUserEmail = prefs.getString('currentUserEmail');
                      if (currentUserEmail == null) {
                        // Fluttertoast.showToast(
                        //   msg: "No user email found. Please log in again.",
                        //   toastLength: Toast.LENGTH_SHORT,
                        //   gravity: ToastGravity.BOTTOM,
                        //   backgroundColor: Colors.red,
                        //   textColor: Colors.white,
                        //   fontSize: 16.0,
                        // );
                        return;
                      }
                      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUserEmail).get();
                      final userData = doc.data();
                      final pdfBytes = await PdfGenerator().generateRestaurantPdf(
                        widget.restaurant,
                        uploadToDrive: false, // No upload
                        currentUserData: userData,
                      );

                      // Generate file name: ClientName_D-M-YY.pdf (current date, +4h offset)
                      final uaeNow = DateTime.now().toUtc().add(const Duration(hours: 4));
                      final day = uaeNow.day;
                      final month = uaeNow.month;
                      final year = uaeNow.year % 100;
                      String clientName = widget.restaurant.name.replaceAll(' ', '_');
                      String fileName = '${clientName}_${day}-${month}-${year}.pdf';

                      // Save PDF to Hive
                      final box = Hive.box('pdfs');
                      await box.put(fileName, pdfBytes);

                      await Printing.layoutPdf(
                        onLayout: (format) async => pdfBytes,
                        name: fileName,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(
    String label,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
    IconData icon,
  ) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (option == currentValue)
                Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20),
              if (option == currentValue) const SizedBox(width: 12),
              Text(
                option,
                style: TextStyle(
                  fontWeight: option == currentValue
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: option == currentValue
                      ? Colors.blue.shade600
                      : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 18),
            const SizedBox(width: 8),
            Text(
              '$label: $currentValue',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEmployeeCard(Employee employee, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      margin: const EdgeInsets.only(bottom: 16, left: 10, right: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetailsScreen(
                employee: employee,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Modern Avatar with gradient
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getAvatarGradient(employee.gender),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColor(employee.gender).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      employee.name.isNotEmpty
                          ? employee.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.position,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Modern Tags
                      Row(
                        children: [
                          _buildModernTag(
                            (employee.gender != null && employee.gender.isNotEmpty) 
                                ? employee.gender 
                                : 'Unknown',
                            _getGenderColor(employee.gender),
                          ),
                          // const SizedBox(width: 8),
                          // _buildModernTag(
                          //   (employee.position != null && employee.position.isNotEmpty) 
                          //       ? employee.position 
                          //       : 'Unknown',
                          //   Colors.blue.shade50,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Modern Trailing Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty
                ? 'No employees found'
                : 'No employees match filters',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Try changing your filter settings',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (searchQuery.isNotEmpty ||
              genderFilter != 'All' ||
              typeFilter != 'All')
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear All Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                    genderFilter = 'All';
                    typeFilter = 'All';
                    _searchController.clear();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Color _getAvatarColor(String? gender) {
    if (gender == null || gender.isEmpty) return Colors.grey;
    switch (gender.toLowerCase()) {
      case 'male':
        return Colors.blue;
      case 'female':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  List<Color> _getAvatarGradient(String? gender) {
    if (gender == null || gender.isEmpty) {
      return [Colors.grey.shade400, Colors.grey.shade600];
    }
    switch (gender.toLowerCase()) {
      case 'male':
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 'female':
        return [Colors.pink.shade400, Colors.pink.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  Color _getGenderColor(String? gender) {
    if (gender == null || gender.isEmpty) return Colors.grey.shade100;
    switch (gender.toLowerCase()) {
      case 'male':
        return Colors.blue.shade50;
      case 'female':
        return Colors.pink.shade50;
      default:
        return Colors.grey.shade100;
    }
  }
}
class _InfoItem extends StatelessWidget {
  final IconData iconData;
  final String label;
  final double iconSize;

  const _InfoItem({
    Key? key,
    required this.iconData,
    required this.label,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          size: iconSize,
          color: Color.fromARGB(255, 24, 119, 126),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}
