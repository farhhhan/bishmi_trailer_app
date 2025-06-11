import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:bishmi_app/presentation/add_restorent_screen/screen/add_list_members.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  late Box<Restaurant> restaurantBox;
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  String filterOrder = 'none'; // 'asc', 'desc', or 'none'

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

  int getUniqueUniformItemNameCount(Restaurant restaurant) {
    final Set<String> processedPositions = {};
    final Set<String> uniqueItemNames = {};

    for (var employee in restaurant.employees) {
      final position = employee.position;
      final gender = employee.gender;

      if (processedPositions.contains(position)) continue;
      processedPositions.add(position);

      final positions = PositionData.positionsByCategory[restaurant.category];
      final positionData = positions?.firstWhere(
        (p) => p.title == position,
        orElse: () => WorkerPosition(title: '', items: {}),
      );

      if (positionData!.title.isEmpty) continue;

      final items = positionData.getUniformItems(gender);
      for (var item in items) {
        uniqueItemNames
            .add(item.name.trim()); // avoid duplicates due to extra spaces
      }
    }

    return uniqueItemNames.length;
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
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () => _showRestaurantDetails(restaurant),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.grey,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.amber.shade100,
                                    child: const Icon(Icons.restaurant),
                                  ),
                                  title: Text(
                                    "${restaurant.name}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(restaurant.category),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () =>
                                          _showRestaurantDetails(restaurant),
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(width: 40),
                                    const Icon(
                                      Icons.people_outline_sharp,
                                      size: 20,
                                      color: Color.fromARGB(255, 24, 119, 126),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${restaurant.employees.length}',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(width: 50),
                                    const Icon(
                                      FontAwesomeIcons.shirt,
                                      size: 15,
                                      color: Color.fromARGB(255, 24, 119, 126),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${getUniqueUniformItemNameCount(restaurant)}',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(width: 50),
                                    const Icon(
                                      FontAwesomeIcons.clock,
                                      size: 15,
                                      color: Color.fromARGB(255, 24, 119, 126),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _getRemainingDaysText(restaurant.date),
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
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
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditRestaurantScreen(restaurant: restaurant)));
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
  State<_RestaurantDetailsBottomSheet> createState() => _RestaurantDetailsBottomSheetState();
}

class _RestaurantDetailsBottomSheetState extends State<_RestaurantDetailsBottomSheet> {
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
      bool matchesGender = genderFilter == 'All' || employee.gender == genderFilter;
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
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header Section
                Container(
                  padding: const EdgeInsets.all(10),
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.restaurant.employees.length.toString() + ' Employees',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stats Row - Shows filtered results
                      Row(
                        children: [
                          _buildStatItem(
                            icon: Icons.people,
                            count: filteredEmployees.length.toString(),
                            label: searchQuery.isNotEmpty || genderFilter != 'All' || typeFilter != 'All' 
                                ? 'Found' : 'Total',
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 20),
                          _buildStatItem(
                            icon: Icons.male,
                            count: filteredEmployees.where((e) => e.gender == 'Male').length.toString(),
                            label: 'Male',
                            color: Colors.green,
                          ),
                          const SizedBox(width: 20),
                          _buildStatItem(
                            icon: Icons.female,
                            count: filteredEmployees.where((e) => e.gender == 'Female').length.toString(),
                            label: 'Female',
                            color: Colors.pink,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Search Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by name or position...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
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
                      
                      const SizedBox(height: 16),
                      
                      // Filter Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Gender',
                              genderFilter,
                              ['All', 'Male', 'Female'],
                              (value) => setState(() => genderFilter = value),
                            ),
                            const SizedBox(width: 12),
                         
                            const SizedBox(width: 12),
                            _buildFilterChip(
                              'Sort',
                              sortOrder,
                              ['A-Z', 'Z-A'],
                              (value) => setState(() => sortOrder = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                
                // Employee List
                Expanded(
                  child: filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isNotEmpty 
                                    ? 'No employees found for "$searchQuery"'
                                    : 'No employees match the selected filters',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (searchQuery.isNotEmpty || genderFilter != 'All' || typeFilter != 'All')
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        searchQuery = '';
                                        genderFilter = 'All';
                                        typeFilter = 'All';
                                        _searchController.clear();
                                      });
                                    },
                                    child: const Text('Clear all filters'),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = filteredEmployees[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: _getAvatarColor(employee.gender),
                                  child: Text(
                                    employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  employee.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      employee.position,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildTag(employee.gender, _getGenderColor(employee.gender)),
                                        const SizedBox(width: 8),
                                        _buildTag(employee.position, Colors.blue.shade100),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
  }
}

Widget _buildStatItem({
  required IconData icon,
  required String count,
  required String label,
  required Color color,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildFilterChip(
  String label,
  String currentValue,
  List<String> options,
  ValueChanged<String> onChanged,
) {
  return PopupMenuButton<String>(
    onSelected: onChanged,
    itemBuilder: (context) => options.map((option) {
      return PopupMenuItem<String>(
        value: option,
        child: Row(
          children: [
            if (option == currentValue)
              const Icon(Icons.check, color: Colors.blue, size: 20),
            if (option == currentValue) const SizedBox(width: 8),
            Text(option),
          ],
        ),
      );
    }).toList(),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: $currentValue',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    ),
  );
}

Widget _buildTag(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Color _getAvatarColor(String gender) {
  switch (gender.toLowerCase()) {
    case 'male':
      return Colors.blue;
    case 'female':
      return Colors.pink;
    default:
      return Colors.grey;
  }
}

Color _getGenderColor(String gender) {
  switch (gender.toLowerCase()) {
    case 'male':
      return Colors.blue.shade100;
    case 'female':
      return Colors.pink.shade100;
    default:
      return Colors.grey.shade100;
  }
}