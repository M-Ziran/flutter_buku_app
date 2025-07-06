import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/api_service.dart';
import 'detail_page.dart';
import 'change_password_page.dart';
import 'widgets/item_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureItems = ApiService().fetchItemsFromJson();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📚 Daftar Buku"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.lock_outline),
            tooltip: "Ganti Password",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChangePasswordPage()),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Gagal memuat data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("📭 Tidak ada data buku"));
          }

          final items = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(
                          title: item.title,
                          subtitle: item.subtitle,
                          description: item.description,
                          image: item.image,
                          link: item.link,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
