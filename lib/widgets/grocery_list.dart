import 'package:flutter/material.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/newitem.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  Widget content = Center(child: Text('No Items added ...'));
  final List<GroceryItem> _groceryItems = [];
  void _addItem() async {
    final savedItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => Newitem()));

    if (savedItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(savedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Create a local variable for the content
    Widget activeContent = const Center(child: Text('No Items added ...'));

    // 2. If items exist, switch activeContent to the ListView
    if (_groceryItems.isNotEmpty) {
      activeContent = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) {
          // rename 'item' to 'index' for clarity
          return Dismissible(
            onDismissed: (direction) => setState(() {
              _groceryItems.removeAt(index);
            }),

            key: ValueKey(_groceryItems[index].id),
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      // 3. Use the local variable here
      body: activeContent,
    );
  }
}
