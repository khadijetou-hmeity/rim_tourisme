import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rim_tourisme/models/restaut.dart';

class VillePage extends StatefulWidget {
  const VillePage({Key? key}) : super(key: key);

  @override
  State<VillePage> createState() => _VillePageState();
}

class _VillePageState extends State<VillePage> {
  final Stream<QuerySnapshot> _villePageStream =
      FirebaseFirestore.instance.collection('ville').snapshots();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Villes'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _villePageStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              var filteredDocs = snapshot.data!.docs.where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return data['nom'].toLowerCase().contains(searchQuery);
              }).toList();

              return GridView.builder(
                padding: EdgeInsets.only(top: 80.0), // Espace pour la barre de recherche flottante
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: filteredDocs.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> data =
                      filteredDocs[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VilleDetailPage(villeData: data),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                            child: Image.network(
                              data['photo'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 120.0,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['nom'],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  data['type'],
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
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
                  hintText: 'Rechercher une ville...',
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



class VilleDetailPage extends StatefulWidget {
  final Map<String, dynamic> villeData;

  const VilleDetailPage({Key? key, required this.villeData}) : super(key: key);

  @override
  _VilleDetailPageState createState() => _VilleDetailPageState();
}

class _VilleDetailPageState extends State<VilleDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.villeData['nom']),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Description'),
            Tab(text: 'Attractions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contenu de l'onglet Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.villeData['photo'] ?? 'https://via.placeholder.com/200',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.villeData['nom'],
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  widget.villeData['type'] ?? 'Type inconnu',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Distance: ${widget.villeData['distance']}',
                  style: TextStyle(fontSize: 16.0),
                ),
                // Ajoutez d'autres détails ici selon vos besoins
                SizedBox(height: 16.0),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.blue),
                      onPressed: () {
                        // Logique pour aimer la photo
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.comment, color: Colors.blue),
                      onPressed: () {
                        // Logique pour ajouter un commentaire
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contenu de l'onglet Attractions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attractions à ${widget.villeData['nom']}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                InkWell(
                onTap: () {
                            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantPage(villeData: widget.villeData),
              ),
            );
                },
                child: _buildAttractionCard('Restaurants', Icons.restaurant),
              ),
                SizedBox(height: 8.0),
              InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogementsPage(villeData: widget.villeData),
                ),
              );
            },
            child: _buildAttractionCard('Logements', Icons.hotel),
          ),
                SizedBox(height: 8.0),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LieuxPage(villeData: widget.villeData),
                      ),
                    );
                  },
                  child: _buildAttractionCard('Lieux à visiter', Icons.place),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(String title, IconData icon) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40.0),
            SizedBox(width: 16.0),
            Text(
              title,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
