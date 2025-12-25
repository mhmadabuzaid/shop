import 'package:flutter/material.dart';
import 'package:shopping_app/models/grocery_item.dart';

class Newitem extends StatefulWidget {
  const Newitem({super.key, required this.newgroceryItem});
  final GroceryItem newgroceryItem;

  @override
  State<Newitem> createState() => _NewitemState();
}

class _NewitemState extends State<Newitem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a new item')),
      body: Padding(padding: EdgeInsets.all(12), child: Text('The form ')),
    );
  }
}
