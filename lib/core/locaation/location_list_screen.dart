import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'add_location.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  List<Map<String, dynamic>> _locations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final data = await DBHelper.instance.getLocations();
    setState(() {
      _locations = data;
      _loading = false;
    });
  }

  Future<void> _deleteLocation(int id) async {
    await DBHelper.instance.deleteLocation(id);
    _loadLocations();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Office Locations")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLocationScreen()),
          );
          _loadLocations();
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _locations.isEmpty
          ? const Center(child: Text("No locations added"))
          : ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (_, i) {
          final loc = _locations[i];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                loc['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Lat: ${loc['latitude']}, Lng: ${loc['longitude']}"),
                  Text("Radius: ${loc['radius']} meters"),
                ],
              ),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  if (value == "delete") {
                    _deleteLocation(loc['id']);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: "delete",
                    child: Text("Delete"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
