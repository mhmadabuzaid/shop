import 'package:flutter/material.dart';
import 'package:shopping_app/data/catagories.dart';
import 'package:shopping_app/models/catagory.dart';
import 'package:shopping_app/models/grocery_item.dart';

class Newitem extends StatefulWidget {
  const Newitem({super.key});

  @override
  State<Newitem> createState() => _NewitemState();
}

class _NewitemState extends State<Newitem> {
  final _formKey = GlobalKey<FormState>();
  var enterdName = "";
  var enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // This updates the variables
      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: enterdName,
          quantity: enteredQuantity,
          category: _selectedCategory,
        ),
      );

      // ONLY proceed if valid
      print(enterdName);
      print(enteredQuantity);
      print(_selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a new item')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 - 50";
                  }
                },
                onSaved: (newValue) => enterdName = newValue!,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text('Quantity')),
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Minimum 1";
                        }
                      },
                      onSaved: (newValue) {
                        enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedCategory,
                      items: [
                        for (final cat in categories.entries)
                          DropdownMenuItem(
                            value: cat.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: cat.value.color,
                                ),
                                SizedBox(width: 6),
                                Text(cat.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        _selectedCategory = value!;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: Text('Reset..'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(onPressed: _saveItem, child: Text('Add Item')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
