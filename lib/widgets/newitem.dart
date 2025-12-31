import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/catagories.dart';
import 'package:shopping_app/models/catagory.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;

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
  var isSending = false;

  void _saveItem() async {
    print("1. Button clicked!"); // Check if button works
    // Validate the form
    final isValid = _formKey.currentState!.validate();
    print("2. Form is valid: $isValid");
    if (isValid) {
      _formKey.currentState!.save();
      isSending = true;

      print("3. Form saved. Name: $enterdName, Quantity: $enteredQuantity");
      final url = Uri.https(
        'shoping-list-8df90-default-rtdb.europe-west1.firebasedatabase.app',
        'shopping-list.json',
      );
      print("4. Sending request to: $url");
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "name": enterdName,
            "quantity": enteredQuantity,
            "category": _selectedCategory.title,
          }),
        );

        print("5. Response received!");
        print("Status Code: ${response.statusCode}");
        print("Body: ${response.body}");

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("6. SUCCESS! Item saved to database.");

          if (!context.mounted) return;

          final resData = json.decode(response.body);
          Navigator.of(context).pop(
            GroceryItem(
              id: resData['name'],
              name: enterdName,
              quantity: enteredQuantity,
              category: _selectedCategory,
            ),
          );

          // Uncomment this to close the screen on success
          // Navigator.of(context).pop(GroceryItem(...));
        } else {
          print("6. FAILED. Server rejected the request.");
        }
      } catch (error) {
        print("CRITICAL ERROR: Could not send request.");
        print(error); // This prints if you have no internet or bad URL
      }
    } else {
      print("2. Validation FAILED. Check your input fields (red error text).");
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
                    onPressed: isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: Text('Reset..'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSending ? null : _saveItem,
                    child: isSending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
