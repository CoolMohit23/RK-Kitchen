import '../models/menu_item.dart';

// Sample menu data
class MenuData {
  static List<MenuItem> getMenuItems() {
    return [
      MenuItem(
        id: '1',
        name: 'Idly',
        description: 'Soft and fluffy steamed rice cakes served with chutney and sambar',
        price: 20.0,
        imageUrl: 'https://via.placeholder.com/150?text=Idly',
        category: 'Breakfast',
      ),
      MenuItem(
        id: '2',
        name: 'Dosa',
        description: 'Crispy fermented rice and lentil crepe served with chutney and sambar',
        price: 50.0,
        imageUrl: 'https://via.placeholder.com/150?text=Dosa',
        category: 'Breakfast',
      ),
      MenuItem(
        id: '3',
        name: 'Vada',
        description: 'Crispy fried savory donut made from lentil batter',
        price: 40.0,
        imageUrl: 'https://via.placeholder.com/150?text=Vada',
        category: 'Breakfast',
      ),
      MenuItem(
        id: '4',
        name: 'Paneer Tikka',
        description: 'Grilled cottage cheese with spices and vegetables',
        price: 180.0,
        imageUrl: 'https://via.placeholder.com/150?text=Paneer+Tikka',
        category: 'Main Course',
      ),
      MenuItem(
        id: '5',
        name: 'Butter Chicken',
        description: 'Chicken cooked in a rich tomato and butter gravy',
        price: 220.0,
        imageUrl: 'https://via.placeholder.com/150?text=Butter+Chicken',
        category: 'Main Course',
      ),
      MenuItem(
        id: '6',
        name: 'Gulab Jamun',
        description: 'Sweet milk solids dumplings soaked in sugar syrup',
        price: 60.0,
        imageUrl: 'https://via.placeholder.com/150?text=Gulab+Jamun',
        category: 'Dessert',
      ),
    ];
  }

  // Get menu items by category
  static List<MenuItem> getMenuItemsByCategory(String category) {
    return getMenuItems().where((item) => item.category == category).toList();
  }

  // Get all categories
  static List<String> getAllCategories() {
    return getMenuItems()
        .map((item) => item.category)
        .toSet() // Convert to Set to remove duplicates
        .toList(); // Convert back to List
  }
}