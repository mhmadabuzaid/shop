import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_app/data/catagories.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/newitem.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _load();
  }

  Future<List<GroceryItem>> _load() async {
    final url = Uri.https(
      'shoping-list-8df90-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery list. Please try again later.');
    }

    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
          )
          .value;

      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    return loadedItems;
  }

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

  void removeItem(GroceryItem item) async {
    final itemIndex = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'shoping-list-8df90-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        setState(() {
          _groceryItems.insert(itemIndex, item);
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not delete item.')),
          );
        }
      }
    } catch (error) {
      setState(() {
        _groceryItems.insert(itemIndex, item);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.hasData) {
            // FIX: One-time Sync
            // If our local list is empty, but the server sent data, fill our local list.
            if (_groceryItems.isEmpty && snapshot.data!.isNotEmpty) {
              _groceryItems = snapshot.data!;
            }

            if (_groceryItems.isEmpty) {
              return const Center(child: Text('No Items added ...'));
            }

            return ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  onDismissed: (direction) {
                    removeItem(_groceryItems[index]);
                  },
                  key: ValueKey(_groceryItems[index].id),
                  background: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withOpacity(0.75),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
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

          return const Center(child: Text('No Items added ...'));
        },
      ),
    );
  }
}
