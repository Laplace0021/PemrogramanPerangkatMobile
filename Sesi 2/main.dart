import 'package:flutter/material.dart';

const String Mnama = 'Muhammad Djibriel Maulidan';
const String Mnim = '20240040239';
const String mProdi = 'Teknik Informatika'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPM Sesi 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        title: const Text(
          'PPM Sesi 2 - $Mnama ($Mnim)',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileCard(),
            SizedBox(height: 16),
            PromoBanner(),
            SizedBox(height: 16),
            ProductCard(
              name: 'Sepatu Sneakers Pria',
              category: 'Fashion',
              price: 250000,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget{
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.person,size:44,color:scheme.primary,),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  const Text(
                    Mnama,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'NIM:$Mnim'
                  ),
                  const Text(mProdi),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (_)=> const Icon(Icons.star, size: 22, color: Colors.amber)
                  ))
                ]
              )
            )
          ]
        )
      )
    );
  }
}
/// Banner promo menggunakan Stack + Positioned
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.local_offer,
              size: 140,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          const Positioned(
            left: 16,
            top: 16,
            child: Text(
              'PROMO SPESIAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              'Diskon hingga 50% hari ini!',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '50% OFF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
/// Kartu produk (StatefulWidget)
class ProductCard extends StatefulWidget {
  final String name;
  final String category;
  final int price;
 
  const ProductCard({
    super.key,
    required this.name,
    required this.category,
    required this.price,
  });
 
  @override
  State<ProductCard> createState() => _ProductCardState();
}
 
class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;
  int _likeCount = 24;
  int _quantity = 1;
 
  String _rupiah(int value) {
    final s = value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '.',
        );
    return 'Rp $s';
  }
 
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      _likeCount += _isFavorite ? 1 : -1;
    });
  }
 
  void _decrease() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }
 
  void _increase() {
    setState(() => _quantity++);
  }
 
  void _addToCart() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity x ${widget.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder gambar produk
          Container(
            height: 160,
            width: double.infinity,
            color: scheme.primaryContainer,
            child: Icon(Icons.shopping_bag, size: 80, color: scheme.primary),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.category),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _rupiah(widget.price),
                  style: TextStyle(
                    fontSize: 16,
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Tombol favorite + jumlah like
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text('$_likeCount Like'),
                  ],
                ),
                const Divider(),
                // Atur jumlah produk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: _decrease,
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: _increase,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 12)),
                        Text(
                          _rupiah(widget.price * _quantity),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Tambah ke Keranjang'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}