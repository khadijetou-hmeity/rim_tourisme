import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
class RestaurantPage extends StatefulWidget {
  final Map<String, dynamic> villeData;

  const RestaurantPage({Key? key, required this.villeData}) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.villeData['nom']} - Restaurants'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), // Coin inférieur gauche arrondi
            bottomRight: Radius.circular(30), // Coin inférieur droit arrondi
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ville')
                .doc(widget.villeData['id'])
                .collection('restaurants')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur de chargement des données'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Aucun restaurant disponible'));
              }

              List<DocumentSnapshot> filteredRestaurants =
                  snapshot.data!.docs.where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return data['nom'].toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredRestaurants.isEmpty) {
                return Center(child: Text('Aucun restaurant correspondant à cette recherche'));
              }

              return GridView.builder(
                padding: EdgeInsets.only(top: 80.0), // Espace pour la barre de recherche flottante
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredRestaurants.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> restaurantData =
                      filteredRestaurants[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailPage(
                            restaurantData: restaurantData,
                            villeData: widget.villeData,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child: Image.network(
                                restaurantData['photo'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              restaurantData['nom'],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un restaurant...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}




class RestaurantDetailPage extends StatefulWidget {
  final Map<String, dynamic> restaurantData;
  final Map<String, dynamic> villeData;

  const RestaurantDetailPage({Key? key, required this.restaurantData, required this.villeData}) : super(key: key);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  Position? _currentPosition;
  double? _distanceInMeters;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifiez si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Les permissions de localisation sont définitivement refusées.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _currentPosition = position;
        _calculateDistance();
      });
    }
  }

  void _calculateDistance() {
    if (_currentPosition != null) {
      GeoPoint geoPoint = widget.restaurantData['localisation'];
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        geoPoint.latitude,
        geoPoint.longitude,
      );
      if (mounted) {
        setState(() {
          _distanceInMeters = distance;
        });
      }
    }
  }

  Future<void> _launchMaps() async {
    if (widget.restaurantData['localisation'] != null) {
      GeoPoint geoPoint = widget.restaurantData['localisation'];
      double latitude = geoPoint.latitude;
      double longitude = geoPoint.longitude;

      final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('geo:$latitude,$longitude?q=$latitude,$longitude'),
        package: 'com.google.android.apps.maps',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await intent.launch();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Impossible de lancer Google Maps')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    GeoPoint geoPoint = widget.restaurantData['localisation'];
    double latitude = geoPoint.latitude;
    double longitude = geoPoint.longitude;
    LatLng location = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.restaurantData['nom']} - ${widget.villeData['nom']}',style: TextStyle(fontSize: 16),),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), // Coin inférieur gauche arrondi
            bottomRight: Radius.circular(30), // Coin inférieur droit arrondi
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  widget.restaurantData['photo'],
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.restaurantData['nom'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.restaurantData['description'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Localisation:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    center: location,
                    zoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: location,
                          // Directly provide the child widget here
                          child: Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (_distanceInMeters != null)
                Text(
                  'Distance: ${(_distanceInMeters! / 1000).toStringAsFixed(2)} km',
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _launchMaps,
                child: Text(
                  'Voir la route sur Google Maps',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Vous pouvez ajouter plus de détails sur le restaurant ici si nécessaire
            ],
          ),
        ),
      ),
    );
  }
}
