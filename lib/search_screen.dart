import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(-25.992120, 28.070070); // Default to Apptechnics
  final String googleApiKey = 'AIzaSyBM2kGthnesN0zLYPYhuy-AZp16KQAdkgM';
  String _locationInfo = 'Apptechnics, South Africa'; // Default location info

  Future<void> _onSearch(String placeId) async {
    // Fetch the place details using the placeId
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final result = jsonResponse['result'];
      final location = result['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];
      final name = result['name'];
      final address = result['formatted_address'];

      setState(() {
        _currentLocation = LatLng(lat, lng);
        _locationInfo = '$name, $address';
        _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
      });
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void _showLocationInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(_locationInfo),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 12),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: _currentLocation,
                infoWindow: InfoWindow(
                  title: 'Location',
                  snippet: _locationInfo,
                ),
                onTap: _showLocationInfo,
              ),
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30),
              shadowColor: Colors.blue[200],
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: TextEditingController(),
                googleAPIKey: googleApiKey,
                inputDecoration: InputDecoration(
                  hintText: 'Search location',
                  contentPadding: const EdgeInsets.all(15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                ),
                debounceTime: 600,
                countries: const ["za"],
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (prediction) {
                  _onSearch(prediction.placeId ?? '');
                },
                itemClick: (prediction) {
                  _onSearch(prediction.placeId ?? '');
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/');
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.logout),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
