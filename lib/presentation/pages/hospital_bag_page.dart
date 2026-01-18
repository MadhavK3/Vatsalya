import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HospitalBagPage extends StatefulWidget {
  const HospitalBagPage({super.key});

  @override
  State<HospitalBagPage> createState() => _HospitalBagPageState();
}

class _HospitalBagPageState extends State<HospitalBagPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<BagItem>> _items = {
    'Mom': [
      BagItem(name: 'Birth Plan & Hospital Notes'),
      BagItem(name: 'Loose Comfortable Clothing'),
      BagItem(name: 'Toiletries (Toothbrush, Deodorant, etc.)'),
      BagItem(name: 'Maternity Pads'),
      BagItem(name: 'Nursing Bras & Breast Pads'),
      BagItem(name: 'Snacks & Drinks'),
      BagItem(name: 'Phone Charger (Long Cable)'),
    ],
    'Baby': [
      BagItem(name: 'Bodysuits & Sleepsuits'),
      BagItem(name: 'Going Home Outfit'),
      BagItem(name: 'Nappies (Newborn size)'),
      BagItem(name: 'Baby Wipes / Cotton Wool'),
      BagItem(name: 'Blanket'),
      BagItem(name: 'Muslin Squares'),
      BagItem(name: 'Car Seat (Installed)'),
    ],
    'Partner': [
      BagItem(name: 'Change of Clothes'),
      BagItem(name: 'Comfortable Shoes'),
      BagItem(name: 'Toiletries'),
      BagItem(name: 'Camera / Phone'),
      BagItem(name: 'Cash for Parking'),
      BagItem(name: 'Pillow'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('hospital_bag_data');
    if (savedData != null) {
      final Map<String, dynamic> decoded = jsonDecode(savedData);
      setState(() {
        decoded.forEach((key, value) {
          if (_items.containsKey(key)) {
            final List<dynamic> list = value;
            for (int i = 0; i < list.length; i++) {
              if (i < _items[key]!.length) {
                _items[key]![i].isDone = list[i]['isDone'] ?? false;
              }
            }
          }
        });
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((key, value) => MapEntry(key, value.map((e) => {'name': e.name, 'isDone': e.isDone}).toList()));
    await prefs.setString('hospital_bag_data', jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Bag'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mom', icon: Icon(Icons.person)),
            Tab(text: 'Baby', icon: Icon(Icons.child_friendly)),
            Tab(text: 'Partner', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _items.keys.map((category) {
          final items = _items[category]!;
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 1,
                    color: Theme.of(context).cardColor,
                    shape: Theme.of(context).cardTheme.shape,
                    child: CheckboxListTile(
                      title: Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: item.isDone ? TextDecoration.lineThrough : null,
                          color: item.isDone 
                            ? Theme.of(context).disabledColor 
                            : Theme.of(context).textTheme.titleMedium?.color
                        )
                      ),
                      value: item.isDone,
                      activeColor: Theme.of(context).colorScheme.primary,
                      checkColor: Theme.of(context).colorScheme.onPrimary,
                      onChanged: (val) {
                        setState(() {
                          item.isDone = val ?? false;
                        });
                        _saveItems();
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BagItem {
  final String name;
  bool isDone;

  BagItem({required this.name, this.isDone = false});
}
