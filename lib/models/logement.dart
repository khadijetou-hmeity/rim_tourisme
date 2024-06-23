import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class LogementsPage extends StatefulWidget {
  final Map<String, dynamic> villeData;

  const LogementsPage({Key? key, required this.villeData}) : super(key: key);

  @override
  _LogementsPageState createState() => _LogementsPageState();
}

class _LogementsPageState extends State<LogementsPage> {
  String searchQuery = '';
  String selectedCategory = ''; // Catégorie de filtrage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.villeData['nom']} - Logements',style: TextStyle(fontSize: 18)),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), // Coin inférieur gauche arrondi
            bottomRight: Radius.circular(30), // Coin inférieur droit arrondi
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                selectedCategory = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '',
                child: Text('Tous'),
              ),
              PopupMenuItem<String>(
                value: 'hotel',
                child: Text('Hotel'),
              ),
              PopupMenuItem<String>(
                value: 'auberge',
                child: Text('Auberge'),
              ),
              PopupMenuItem<String>(
                value: 'appartement',
                child: Text('Appartement'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ville')
                .doc(widget.villeData['id'])
                .collection('hotels')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur de chargement des données'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Aucun hôtel disponible'));
              }

              // Filtrer les hôtels en fonction de la recherche et de la catégorie sélectionnée
              List<DocumentSnapshot> filteredHotels = snapshot.data!.docs.where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return data['nom'].toLowerCase().contains(searchQuery) &&
                    (selectedCategory.isEmpty || data['categorie'] == selectedCategory);
              }).toList();

              if (filteredHotels.isEmpty) {
                return Center(child: Text('Aucun hôtel correspondant à cette recherche'));
              }

              return GridView.builder(
                padding: EdgeInsets.only(top: 80.0), // Espace pour la barre de recherche flottante
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredHotels.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> hotelData =
                      filteredHotels[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelDetailPage(hotelData: hotelData, villeData: widget.villeData),
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
                                hotelData['photo'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              hotelData['nom'],
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
                  hintText: 'Rechercher un hôtel...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
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

class HotelDetailPage extends StatelessWidget {
  final Map<String, dynamic> hotelData;
  final Map<String, dynamic> villeData;

  const HotelDetailPage({Key? key, required this.hotelData, required this.villeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GeoPoint geoPoint = hotelData['localisation'];
    double latitude = geoPoint.latitude;
    double longitude = geoPoint.longitude;
    LatLng location = LatLng(latitude, longitude);

    // Récupérer le nom de la ville
    String cityName = villeData['nom'];

    Future<void> _launchMaps() async {
      final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('geo:$latitude,$longitude?q=$latitude,$longitude'),
        package: 'com.google.android.apps.maps',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await intent.launch();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de lancer Google Maps')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${hotelData['nom']} - $cityName', style: TextStyle(fontSize: 18)), // Utilisation du nom de la ville dans l'AppBar
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
              SizedBox(
                height: 200.0, // Hauteur pour l'image
                child: Image.network(
                  hotelData['photo'],
                  fit: BoxFit.contain, // Afficher l'image sans la couper
                ),
              ),
              SizedBox(height: 20),
              Text(
                hotelData['nom'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                hotelData['description'],
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
              TextButton(
                onPressed: _launchMaps,
                child: Text(
                  'Voir la route sur Google Maps',
                  style: TextStyle(
                    color: Color.fromARGB(255, 9, 114, 46),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Vous pouvez ajouter plus de détails sur l'hôtel ici si nécessaire
            ],
          ),
        ),
      ),
    );
  }
}