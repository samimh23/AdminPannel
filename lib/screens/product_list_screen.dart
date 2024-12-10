import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'create_product_screen.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  final List<String> categories = ["All", "Vitamins", "MultiVit", "Protein"];

  void _showProductDetailsDialog(BuildContext context, product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Description: ${product.description ?? 'No description available'}"),
            Text("Category: ${product.category}"),
            Text("Price: \$${product.price.toStringAsFixed(2)}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}


  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (searchQuery.isEmpty && selectedCategory == "All") {
      productProvider.fetchProducts();
    } else if (selectedCategory != "All" && searchQuery.isEmpty) {
      productProvider.fetchProductsByCategory(selectedCategory);
    } else if (selectedCategory == "All" && searchQuery.isNotEmpty) {
      productProvider.fetchProductsByName(searchQuery);
    } else if (selectedCategory != "All" && searchQuery.isNotEmpty) {
      productProvider.fetchProductsByName(searchQuery);
      productProvider.fetchProductsByCategory(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const Icon(Icons.local_pharmacy, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              "Pharmacy Marketplace",
              style: TextStyle(fontSize: 23, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Row for Search bar and Category dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Styled Search Bar
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by name",
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    ),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                      _fetchProducts();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Styled Category Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    ),
                    dropdownColor: Colors.blue[100],
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    onChanged: (category) {
                      setState(() {
                        selectedCategory = category!;
                      });
                      _fetchProducts();
                    },
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Display products in a table format
          Expanded(
            child: productProvider.products.isEmpty
                ? const Center(child: Text('No products found'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Modify   Delete')),
                      ],
                      rows: productProvider.products.map<DataRow>((product) {
                        return DataRow(cells: [
                         DataCell(
  Text(product.name),
  onTap: () {
    _showProductDetailsDialog(context, product);
  },
),

                          DataCell(Text(product.category)),
                          DataCell(Text("\$${product.price.toStringAsFixed(2)}")),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.yellow),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProductScreen(
                                        product: product,
                                      ),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Show confirmation dialog before deleting
                                  bool? confirmDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: const Text(
                                            "Are you sure you want to delete this product?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  // If the user confirmed, proceed to delete the product
                                  if (confirmDelete == true) {
                                    await productProvider.deleteProduct(product.id);
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProductScreen(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}
