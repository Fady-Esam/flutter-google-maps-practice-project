import 'dart:convert';
import 'dart:developer';
import 'package:apply_google_maps/secrets/secretes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Places API Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GooglePlacesTest(),
    );
  }
}

class GooglePlacesTest extends StatefulWidget {
  const GooglePlacesTest({super.key});

  @override
  _GooglePlacesTestState createState() => _GooglePlacesTestState();
}

class _GooglePlacesTestState extends State<GooglePlacesTest> {
  final TextEditingController _searchController = TextEditingController();
  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(
    37.7749,
    -122.4194,
  ); // Default to San Francisco
  List<dynamic> _places = [];

  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  String getPlacesUrl(String query) {
  return "https://maps.googleapis.com/maps/api/place/textsearch/json"
         "?query=${Uri.encodeComponent(query)}"
         "&key=${Secrets.googleApiKey}";
}

  Future<void> _searchPlacesByName(String query) async {
    String url =
      getPlacesUrl(query);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log(data.toString());
      setState(() {
        _places = data["results"];
      });
    }
  }

  void _selectPlace(double lat, double lng, String name) {
    setState(() {
      _initialPosition = LatLng(lat, lng);
      _searchController.text = name;
      _places = [];
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Places API Test")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Enter place name...",
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  _searchPlacesByName(query);
                } else {
                  setState(() {
                    _places = [];
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_places[index]["name"]),
                  subtitle: Text(_places[index]["formatted_address"] ?? ""),
                  onTap: () {
                    double lat = _places[index]["geometry"]["location"]["lat"];
                    double lng = _places[index]["geometry"]["location"]["lng"];
                    _selectPlace(lat, lng, _places[index]["name"]);
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              onMapCreated: _onMapCreated,
              markers: {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: _initialPosition,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
