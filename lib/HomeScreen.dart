import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Product/Product.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];

  TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:8081/product/find-all'));

    if (response.statusCode == 200) {
      setState(() {
        allProducts = json.decode(response.body);
        filteredProducts = allProducts;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void filterProducts(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredProducts = allProducts.where((product) => product['title'].toLowerCase().contains(query.toLowerCase())).toList();
      });
    } else {
      setState(() {
        filteredProducts = allProducts;
      });
    }
  }

  void filterProductsByCategory(String category) {
    if (category == null || category == 'All') {
      setState(() {
        filteredProducts = allProducts;
        selectedCategory = 'All';
      });
    } else {
      setState(() {
        filteredProducts = allProducts.where((product) => product['category'] == category).toList();
        selectedCategory = category;
      });
    }
  }

  @override
  void initState() {
    fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ALL PRODUCTS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildSearchBar(),
              SizedBox(height: 20),
              _buildCategories(),
              SizedBox(height: 20),
              _buildProductList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Search for products',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: filterProducts,
    );
  }

  Widget _buildCategories() {
    List<String> categories = ['All', 'Kaos', 'Jaket', 'Celana', 'Celana Panjang'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<String>(
          value: selectedCategory,
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: filterProductsByCategory,
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Container(
        height: 350,
        child: filteredProducts.length > 0
        ? ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredProducts.length,
        itemBuilder: (ctx, index) => ProductItem(
        product: Product(
        id: filteredProducts[index]['id'],
        title: filteredProducts[index]['title'],
          description: filteredProducts[index]['description'],
          imageUrl: filteredProducts[index]['imageUrl'],
          price: filteredProducts[index]['price'],
          category: filteredProducts[index]['category'],
        ),
        ),
        )
            : Center(
          child: Text(
            'No products found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 20),
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              product.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '${product.price}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              product.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              product.description,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '${product.price}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
