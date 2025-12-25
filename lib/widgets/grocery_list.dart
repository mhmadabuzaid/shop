import 'package:flutter/material.dart';
import 'package:shopping_app/data/dummy_item.dart';
import 'package:shopping_app/widgets/newitem.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Grocaries')),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, item) {
          return ListTile(
            title: Text(groceryItems[item].name),
            leading: Container(
              width: 24,
              height: 24,
              color: groceryItems[item].category.color,
            ),
            trailing: Text(groceryItems[item].quantity.toString()),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => Newitem(newgroceryItem: groceryItems[item]),
              ),
            ),
          );
        },
      ),
    );
  }
}
