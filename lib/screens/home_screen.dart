import 'package:flutter/material.dart';
import '../db/product_repository.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final ProductRepository _productRepository = ProductRepository();

  late Future<List<Product>> _productList = Future.value([]);
  final Set<Product> _selectedProducts = {}; // Multi-selection set
  Product? _highlightedProduct; // Tracks the last tapped product
  bool _isSelecting = false; // Tracks if multi-select mode is active

  @override
  void initState() {
    super.initState();
    _refreshProductList();
  }

  Future<void> _refreshProductList() async {
    final products = await _productRepository.getAllProducts();
    setState(() {
      _productList = Future.value(products);
    });
  }

  void _clearFields() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _selectedProducts.clear();
    _highlightedProduct = null;
    _isSelecting = false;
  }

  void _toggleSelection(Product product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }

      if (_selectedProducts.isEmpty) {
        _isSelecting = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite CRUD')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    final product = Product(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                    );
                    await _productRepository.insertProduct(product);
                    _refreshProductList();
                    _clearFields();
                  },
                  child: Text('Create'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () async {
                    if (_highlightedProduct != null) {
                      final updatedProduct = Product(
                        id: _highlightedProduct!.id, // Use last tapped product for update
                        name: _nameController.text,
                        description: _descriptionController.text,
                        price: double.parse(_priceController.text),
                      );
                      await _productRepository.updateProduct(updatedProduct);
                      _refreshProductList();
                      _clearFields();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a product to update')),
                      );
                    }
                  },
                  child: Text('Update'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    if (_selectedProducts.isNotEmpty) {
                      for (final product in _selectedProducts) {
                        await _productRepository.deleteProduct(product.id!);
                      }
                      _refreshProductList();
                      _clearFields();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select at least one product to delete')),
                      );
                    }
                  },
                  child: Text('Delete'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Price (Rs)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.black),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      final isHighlighted = _highlightedProduct == product;
                      final isSelected = _selectedProducts.contains(product);

                      return GestureDetector(
                        onTap: () {
                          if (_isSelecting) {
                            _toggleSelection(product);
                          } else {
                            setState(() {
                              _highlightedProduct = product; // Track last tapped product
                              _nameController.text = product.name;
                              _descriptionController.text = product.description;
                              _priceController.text = product.price.toString();
                              _selectedProducts.clear(); // Clear multi-selection
                            });
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _isSelecting = true;
                            _toggleSelection(product);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue[100] // Multi-selection highlight
                                : isHighlighted
                                ? Colors.green[100] // Single-tap highlight
                                : Colors.transparent,
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 1.5)
                                : isHighlighted
                                ? Border.all(color: Colors.green, width: 1.5)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(product.name)),
                              Expanded(flex: 3, child: Text(product.description)),
                              Expanded(flex: 1, child: Text('Rs ${product.price}')),
                            ],
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
      ),
    );
  }
}
