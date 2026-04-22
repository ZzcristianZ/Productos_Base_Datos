import 'package:flutter/material.dart';
import 'package:segundoparcial/data/product_datasource.dart';
import 'package:segundoparcial/domain/model/product_model.dart';
import 'package:segundoparcial/domain/notifier/products_notifier.dart';

class InfiniteScroll extends StatefulWidget {
  const InfiniteScroll({super.key});

  @override
  State<InfiniteScroll> createState() => _InfiniteScrollState();
}

class _InfiniteScrollState extends State<InfiniteScroll> {
  final _scrollController = ScrollController();
  final _datasource = ProductDatasource();
  final _notifier = ProductsNotifier.instance;

  final List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  static const int _limit = 5;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
    _notifier.addListener(_onNewProduct);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _notifier.removeListener(_onNewProduct);
    super.dispose();
  }

  void _onNewProduct() {
    final product = _notifier.latest;
    if (product == null) return;
    _notifier.consume();

    setState(() => _products.insert(0, product));

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels + 200 >=
        _scrollController.position.maxScrollExtent) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final newProducts = await _datasource.getProducts(
        limit: _limit,
        skip: _skip,
      );
      setState(() {
        _products.addAll(newProducts);
        _skip += _limit;
        _hasMore = newProducts.length == _limit;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando productos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForm() async {
  await Navigator.pushNamed(context, '/formulario');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Agregar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 6,
        tooltip: 'Nuevo producto',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _products.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _products.length + 1,
              itemBuilder: (context, index) {
                if (index == _products.length) {
                  return _buildFooter();
                }
                return _ProductCard(product: _products[index]);
              },
            ),
    );
  }

  Widget _buildFooter() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No hay más productos',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('💲 ${product.price.toStringAsFixed(2)}'),
                Text('⭐ ${product.rating.toStringAsFixed(1)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text('Marca: ${product.brand}'),
            Text('Categoría: ${product.category}'),
            Text('Stock: ${product.stock}'),
            if (product.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: product.tags
                    .map(
                      (t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
