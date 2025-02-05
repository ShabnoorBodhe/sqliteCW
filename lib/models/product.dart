class Product {
  int? id;
  String name;
  String description;
  double price;

  Product({this.id, required this.name, required this.description, required this.price});

  // Convert a Product object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }

  // Convert a Map object to a Product object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
    );
  }
}
