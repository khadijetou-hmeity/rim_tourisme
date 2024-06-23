import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rim_tourisme/models/lieux.dart';

class Meilleurs extends StatefulWidget {
  @override
  _MeilleursState createState() => _MeilleursState();
}

class _MeilleursState extends State<Meilleurs> {
  String categorieSelectionnee = '';
  bool sortByPopularity = false;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meilleurs Lieux',style: TextStyle(fontSize: 18)),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                if (value == 'Popularité') {
                  sortByPopularity = !sortByPopularity;
                } else {
                  categorieSelectionnee = value;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '',
                child: Text('Tous'),
              ),
              PopupMenuItem<String>(
                value: 'Plage',
                child: Text('Plage'),
              ),
              PopupMenuItem<String>(
                value: 'Montagnes',
                child: Text('Montagnes'),
              ),
              PopupMenuItem<String>(
                value: 'Lacs',
                child: Text('Lacs'),
              ),
              PopupMenuItem<String>(
                value: 'Oasis',
                child: Text('Oasis'),
              ),
              PopupMenuItem<String>(
                value: 'Historique',
                child: Text('Lieux historique'),
              ),
              PopupMenuItem<String>(
                value: 'Popularité',
                child: Text('Popularité'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un lieu...',
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
          Expanded(child: _buildGrid(context)),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      future: _getTouristicPlaces(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun lieu touristique trouvé.'));
        } else {
          List<DocumentSnapshot<Map<String, dynamic>>> filteredPlaces = snapshot.data!;

          // Filtrer les lieux en fonction de la catégorie sélectionnée
          if (categorieSelectionnee.isNotEmpty) {
            filteredPlaces = filteredPlaces.where((place) {
              return place.data()?['categorie']?.contains(categorieSelectionnee) ?? false;
            }).toList();
          }

          // Filtrer les lieux en fonction de la requête de recherche
          if (searchQuery.isNotEmpty) {
            filteredPlaces = filteredPlaces.where((place) {
              String nomLieu = place.data()?['nom']?.toLowerCase() ?? '';
              return nomLieu.contains(searchQuery);
            }).toList();
          }

          // Trier par popularité si demandé
          if (sortByPopularity) {
            filteredPlaces.sort((a, b) => (b.data()?['likes'] ?? 0).compareTo(a.data()?['likes'] ?? 0));
          }

          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.9, // Aspect ratio for the cards (adjust as needed)
            ),
            itemCount: filteredPlaces.length,
            itemBuilder: (context, index) {
              var place = filteredPlaces[index];
              String nomLieu = place.data()?['nom'] ?? 'Nom de lieu non trouvé';
              String idVille = place.reference.parent.parent!.id; // City ID
              String nomVille = ''; // City name to retrieve

              return FutureBuilder<String>(
                future: _getNomVille(idVille),
                builder: (context, snapshotVille) {
                  if (snapshotVille.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshotVille.hasError) {
                    return Text('Erreur: ${snapshotVille.error}');
                  } else {
                    nomVille = snapshotVille.data ?? 'Nom de ville non trouvé';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LieuDetailsPage(
                              villeId: idVille,
                              villeNom: nomVille,
                              lieuData: place.data() ?? {}, // Handle nullable data
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                              child: Image.network(
                                place.data()?['photo'] ?? '', // Handle nullable photo URL
                                fit: BoxFit.cover,
                                height: 120, // Reduced image height
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomLieu,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _getTouristicPlaces() async {
    QuerySnapshot<Map<String, dynamic>> villesSnapshot = await FirebaseFirestore.instance.collection('ville').get();
    List<DocumentSnapshot<Map<String, dynamic>>> touristicPlaces = [];

    for (var ville in villesSnapshot.docs) {
      QuerySnapshot<Map<String, dynamic>> lieuxSnapshot = await ville.reference.collection('lieux')
          .where('touristiques', isEqualTo: true).get();
      
      for (var lieu in lieuxSnapshot.docs) {
        var likesSnapshot = await lieu.reference.collection('likes').get();
        int likesCount = likesSnapshot.size;

        var lieuData = lieu.data();
        if (lieuData != null) {
          lieuData['likes'] = likesCount;
          touristicPlaces.add(lieu as DocumentSnapshot<Map<String, dynamic>>);
        }
      }
    }

    return touristicPlaces;
  }

  Future<String> _getNomVille(String idVille) async {
    DocumentSnapshot<Map<String, dynamic>> villeSnapshot = await FirebaseFirestore.instance.collection('ville').doc(idVille).get();
    return villeSnapshot.data()?['nom'] ?? 'Nom de ville non trouvé';
  }
}
