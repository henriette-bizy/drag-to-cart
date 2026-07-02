import 'package:flutter/material.dart';

void main() => runApp(const DragCartApp());

class DragCartApp extends StatelessWidget {
  const DragCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag to Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const ShopPage(),
    );
  }
}

// A simple product model.
class Product {
  final String name;
  final String emoji;
  final double price;
  const Product(this.name, this.emoji, this.price);
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // Products shown in the shop.
  final List<Product> _products = const [
    Product('Coffee', '☕', 3.50),
    Product('Burger', '🍔', 6.00),
    Product('Pizza', '🍕', 8.50),
    Product('Apple', '🍎', 1.20),
  ];

  // Items dropped into the cart.
  final List<Product> _cart = [];

  // --- Live toggles so I can change Draggable properties during the demo ---
  bool _lockVertical = false; // controls `axis`
  bool _showGhost = false;    // controls `childWhenDragging`
  bool _bigFeedback = false;  // controls `feedback`

  double get _total => _cart.fold(0, (sum, item) => sum + item.price);

  void _addToCart(Product p) {
    setState(() => _cart.add(p));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} added to cart'),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛒 Drag to Cart')),
      body: Column(
        children: [
          _buildControls(),
          const Divider(height: 1),
          // Product grid — each product is a Draggable.
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: _products.map(_buildDraggableProduct).toList(),
            ),
          ),
          // Cart — a DragTarget that receives dropped products.
          _buildCart(),
        ],
      ),
    );
  }

  // Switches to toggle each property live during the talk.
  Widget _buildControls() {
    return Column(
      children: [
        SwitchListTile(
          dense: true,
          title: const Text('Lock to vertical axis  (axis)'),
          value: _lockVertical,
          onChanged: (v) => setState(() => _lockVertical = v),
        ),
        SwitchListTile(
          dense: true,
          title: const Text('Show ghost while dragging  (childWhenDragging)'),
          value: _showGhost,
          onChanged: (v) => setState(() => _showGhost = v),
        ),
        SwitchListTile(
          dense: true,
          title: const Text('Enlarge drag feedback  (feedback)'),
          value: _bigFeedback,
          onChanged: (v) => setState(() => _bigFeedback = v),
        ),
      ],
    );
  }

  // One product card wrapped in a Draggable<Product>.
  Widget _buildDraggableProduct(Product p) {
    final card = _ProductCard(product: p);

    return Draggable<Product>(
      // data: the value handed to the DragTarget on drop.
      data: p,

      // PROPERTY 3 — axis:
      // null (default) = drag any direction; Axis.vertical = up/down only.
      axis: _lockVertical ? Axis.vertical : null,

      // PROPERTY 1 — feedback (REQUIRED, no default):
      // the widget shown under the finger while dragging.
      feedback: SizedBox(
        width: 150,
        child: _bigFeedback
            ? Transform.scale(
                scale: 1.25,
                child: _ProductCard(product: p, dragging: true),
              )
            : _ProductCard(product: p, dragging: true),
      ),

      // PROPERTY 2 — childWhenDragging:
      // null (default) = original stays visible; here we show a faded ghost.
      childWhenDragging: _showGhost ? Opacity(opacity: 0.25, child: card) : null,

      // child: the normal resting appearance.
      child: card,
    );
  }

  // The cart drop zone.
  Widget _buildCart() {
    return DragTarget<Product>(
      // Fires when a Draggable is dropped on this target.
      onAcceptWithDetails: (details) => _addToCart(details.data),
      builder: (context, candidate, rejected) {
        // `candidate` is non-empty while a valid item hovers over the cart.
        final hovering = candidate.isNotEmpty;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: hovering ? Colors.teal.shade200 : Colors.teal.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hovering ? 'Drop to add!' : 'Cart: ${_cart.length} item(s)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

// A small reusable product card.
class _ProductCard extends StatelessWidget {
  final Product product;
  final bool dragging;
  const _ProductCard({required this.product, this.dragging = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Material gives the floating feedback a nice shadow while dragging.
      elevation: dragging ? 10 : 2,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(product.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('\$${product.price.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}