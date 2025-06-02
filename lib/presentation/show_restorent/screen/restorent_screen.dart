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

  @override
  void initState() {
    super.initState();
    restaurantBox = Hive.box<Restaurant>('restaurants');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddRestaurant(),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Restaurant>>(
        valueListenable: restaurantBox.listenable(),
        builder: (context, box, _) {
          final restaurants = box.values.toList().cast<Restaurant>();
          
          if (restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
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
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
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
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
                      SnackBar(content: Text("${restaurant.name} deleted")),
                    );
                  }
                },
                child: ListTile(
                  onTap: () => _showRestaurantDetails(restaurant),
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: const Icon(Icons.restaurant),
                  ),
                  title: Text(restaurant.name),
                  subtitle: Text(restaurant.category),
                  trailing: Text(
                    '${restaurant.employees.length} employees',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddRestaurant(),
        backgroundColor: const Color(0xFFF0B623),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToAddRestaurant() {
    // You'll need to implement this navigation to your restaurant creation screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRestaurantScreen()));
  }

  void _navigateToEditRestaurant(Restaurant restaurant) {
    // You'll need to implement this navigation to your restaurant edit screen
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => EditRestaurantScreen(restaurant: restaurant))
    // );
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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
                          final employee = restaurant.employees[index];
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
                  // Navigate to employee list for this restaurant
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