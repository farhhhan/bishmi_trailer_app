import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
        title:
            const Text('Saved Lists', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (filterOrder != 'none')
            const PopupMenuDivider(),
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
                final allRestaurants =
                    box.values.toList().cast<Restaurant>();
                final filteredRestaurants =
                    _filterRestaurants(allRestaurants);

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
                          onTap: () =>
                                      _showRestaurantDetails(restaurant),
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
                                  title: Text(restaurant.name),
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
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                restaurant.category,
                style:
                    TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Phone: ${restaurant.mobile}'),
              const SizedBox(height: 20),
              const Text(
                'Employees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: restaurant.employees.isEmpty
                    ? const Center(child: Text('No employees yet'))
                    : ListView.builder(
                        itemCount: restaurant.employees.length,
                        itemBuilder: (context, index) {
                          final employee =
                              restaurant.employees[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(employee.name),
                            subtitle: Text(employee.position),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to full employee list
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => EmployeeListScreen(restaurant: restaurant)
                  // ));
                },
                child: const Text('View Full Employee List'),
              ),
            ],
          ),
        );
      },
    );
  }
}
