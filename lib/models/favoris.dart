import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rim_tourisme/models/lieux.dart';

class FavoriteButton extends StatefulWidget {
  final String lieuId;
  final String villeId; // Ajouter l'ID de la ville
  final String villeNom;
  final Map<String, dynamic> lieuData;

  FavoriteButton({
    required this.lieuId,
    required this.villeId,
    required this.lieuData,
    required this.villeNom,
  });
  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  void checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot favoriteSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.lieuId)
          .get();

      setState(() {
        isFavorite = favoriteSnapshot.exists;
      });

      print('Favorite status: $isFavorite');
    } else {
      print('User is not logged in');
    }
  }

void _toggleFavorite() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentReference favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.lieuId);

    if (isFavorite) {
      await favoriteRef.delete();
      print('Removed from favorites');
    } else {
      // Créez un nouveau document dans la collection des favoris
      await favoriteRef.set({
        'lieuId': widget.lieuId,
        'villeId': widget.villeId,
        'villeNom': widget.villeNom,
        ...widget.lieuData, // Étendez les données existantes du lieu
      });
      print('Added to favorites');
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  } else {
    print('User is not logged in');
  }
}

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite
            ? Color.fromARGB(255, 108, 1, 1)
            : Color.fromARGB(255, 49, 47, 47), // Rouge si favori, sinon blanc
      ),
      onPressed: _toggleFavorite,
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Favoris'),
          backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        ),
        body: Center(
          child: Text('Veuillez vous connecter pour voir vos favoris.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favoris'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un favori...',
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
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('favorites')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun favori trouvé'));
                }

                var favorites = snapshot.data!.docs;

                if (favorites.isEmpty) {
                  return Center(child: Text('Aucun favori trouvé'));
                }

                var filteredFavorites = favorites.where((favorite) {
                  var lieuData = favorite.data() as Map<String, dynamic>;
                  var nom = lieuData['nom'].toString().toLowerCase();
                  var query = _searchController.text.toLowerCase();
                  return nom.contains(query);
                }).toList();

                if (filteredFavorites.isEmpty) {
                  return Center(child: Text('Aucun favori trouvé'));
                }

                return ListView.builder(
                  itemCount: filteredFavorites.length,
                  itemBuilder: (context, index) {
                    var favorite = filteredFavorites[index];
                    var lieuData = favorite.data() as Map<String, dynamic>;

                    if (!lieuData.containsKey('photo') ||
                        !lieuData.containsKey('nom') ||
                        !lieuData.containsKey('villeId') ||
                        !lieuData.containsKey('villeNom')) {
                      return ListTile(
                        title: Text('Données de lieu invalides'),
                        subtitle: Text('Vérifiez les données de Firestore.'),
                      );
                    }

                    String photo = lieuData['photo'];
                    String nom = lieuData['nom'];
                    String villeNom = lieuData['villeNom'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          print('Navigating to details of $nom');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LieuDetailsPage(
                                villeId: lieuData['villeId'],
                                villeNom: villeNom,
                                lieuData: lieuData,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photo,
                                fit: BoxFit.cover,
                                height: 200,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nom,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    villeNom,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: const Color.fromARGB(255, 63, 60, 60),
                                    ),
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
          ),
        ],
      ),
    );
  }
}

