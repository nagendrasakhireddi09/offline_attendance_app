
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../db/db_helper.dart';

const String kGoogleApiKey = "AIzaSyBxcfQS6lgMwyOSmk37BvlAqIKoQwExwzM";

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  GoogleMapController? _mapController;

  LatLng? _selectedLatLng;
  String _address = "";
  double _radius = 100;

  final TextEditingController _locationNameController =
  TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final GoogleMapsPlaces _places =
  GoogleMapsPlaces(apiKey: kGoogleApiKey);

  bool _loading = true;
  bool _searching = false;
  List<Prediction> _predictions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showSuggestions = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _locationNameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ---------------- AUTOCOMPLETE ON TEXT CHANGE ----------------
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer for debouncing (300ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _getAutocompletePredictions(query);
    });
  }

  Future<void> _getAutocompletePredictions(String query) async {
    if (query.length < 2) {
      if (mounted) {
        setState(() {
          _predictions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    try {
      final response = await _places.autocomplete(
        query,
        components: [Component(Component.country, "in")],
        language: "en",
      );

      if (mounted) {
        setState(() {
          _predictions = response.predictions;
          _showSuggestions = response.predictions.isNotEmpty && _searchFocusNode.hasFocus;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictions = [];
          _showSuggestions = false;
        });
      }
    }
  }

  // ---------------- CURRENT LOCATION ----------------
  Future<void> _loadCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _selectedLatLng = LatLng(pos.latitude, pos.longitude);
    await _getAddressFromLatLng(_selectedLatLng!);

    setState(() => _loading = false);
  }

  // ---------------- ADDRESS ----------------
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    final placemarks =
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      _address =
      "${p.name}, ${p.street}, ${p.locality}, ${p.administrativeArea}";
    }
  }

  // ---------------- SELECT PLACE FROM PREDICTION ----------------
  Future<void> _selectPlace(Prediction prediction) async {
    if (prediction.placeId == null) return;

    setState(() {
      _searching = true;
      _showSuggestions = false;
    });

    _searchController.text = prediction.description ?? "";
    _searchFocusNode.unfocus();

    try {
      final detail = await _places.getDetailsByPlaceId(prediction.placeId!);

      if (detail.result.geometry?.location == null) {
        _show("Could not get location details for this place ");
        setState(() => _searching = false);
        return;
      }

      final loc = detail.result.geometry!.location;

      _selectedLatLng = LatLng(loc.lat, loc.lng);
      _locationNameController.text = prediction.description ?? "";

      await _getAddressFromLatLng(_selectedLatLng!);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLatLng!, 16),
      );

      setState(() => _searching = false);
    } catch (e) {
      _show("Failed to load place: ${e.toString()}");
      setState(() => _searching = false);
    }
  }

  // ---------------- SAVE ----------------
  Future<void> _saveLocation() async {
    if (_selectedLatLng == null ||
        _locationNameController.text.trim().isEmpty) {
      _show("Enter location name");
      return;
    }

    await DBHelper.instance.insertLocation(
      _locationNameController.text.trim(),
      _selectedLatLng!.latitude,
      _selectedLatLng!.longitude,
      _radius,
    );

    _show("Location added successfully ✅");
    Navigator.pop(context);
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Location"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // ---------------- SEARCH FIELD WITH SUGGESTIONS ----------------
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    enabled: !_searching,
                    decoration: InputDecoration(
                      hintText: "Search place",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _predictions = [];
                                  _showSuggestions = false;
                                });
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (_predictions.isNotEmpty) {
                        _selectPlace(_predictions.first);
                      }
                    },
                  ),
                  // Suggestions List
                  if (_showSuggestions && _predictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _predictions.length > 5 ? 5 : _predictions.length,
                        itemBuilder: (context, index) {
                          final prediction = _predictions[index];
                          return ListTile(
                            leading: const Icon(Icons.place, color: Colors.blue),
                            title: Text(
                              prediction.description ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () => _selectPlace(prediction),
                            dense: true,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ---------------- MAP ----------------
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLatLng!,
                  zoom: 16,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (c) => _mapController = c,
                onTap: (latLng) async {
                  _selectedLatLng = latLng;
                  await _getAddressFromLatLng(latLng);
                  setState(() {});
                },
                markers: {
                  Marker(
                    markerId: const MarkerId("selected"),
                    position: _selectedLatLng!,
                    draggable: true,
                    onDragEnd: (latLng) async {
                      _selectedLatLng = latLng;
                      await _getAddressFromLatLng(latLng);
                      setState(() {});
                    },
                  ),
                },
                circles: {
                  Circle(
                    circleId: const CircleId("radius"),
                    center: _selectedLatLng!,
                    radius: _radius,
                    fillColor: Colors.blue.withOpacity(0.25),
                    strokeColor: Colors.blue,
                    strokeWidth: 2,
                  ),
                },
              ),
            ),

            // ---------------- DETAILS ----------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _locationNameController,
                    decoration: const InputDecoration(
                      labelText: "Location Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _info("Address", _address),
                  _info("Latitude",
                      _selectedLatLng!.latitude.toString()),
                  _info("Longitude",
                      _selectedLatLng!.longitude.toString()),


                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Radius"),
                      Text("${_radius.toInt()} m",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),

                  Slider(
                    value: _radius,
                    min: 50,
                    max: 500,
                    divisions: 9,
                    label: "${_radius.toInt()} m",
                    onChanged: (val) =>
                        setState(() => _radius = val),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveLocation,
                      child: const Text("Save Location"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _info(String t, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t,
                style:
                const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(v,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
