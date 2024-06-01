import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.villeData['nom']} - Logements'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
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

              // Filtrer les hôtels en fonction de la recherche
              List<DocumentSnapshot> filteredHotels = snapshot.data!.docs
                  .where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return data['nom'].toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredHotels.isEmpty) {
                return Center(
                    child: Text('Aucun hôtel correspondant à cette recherche'));
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
                      // Logique pour afficher les détails de l'hôtel, si nécessaire
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

              List<DocumentSnapshot> filteredRestaurants = snapshot.data!.docs.where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return data['nom'].toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredRestaurants.isEmpty) {
                return Center(child: Text('Aucun restaurant correspondant à cette recherche'));
              }

              return Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: ListView(
                  children: filteredRestaurants.map((doc) {
                    final restaurant = doc.data() as Map<String, dynamic>;
                    return _buildPlaceCard(context, doc.id, restaurant);
                  }).toList(),
                ),
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

  Widget _buildPlaceCard(BuildContext context, String restaurantId, Map<String, dynamic> restaurantData) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantDetailPage(
                  villeId: widget.villeData['id'],
                  restaurantId: restaurantId,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                restaurantData['photo'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurantData['nom'] ?? 'Nom inconnu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentSection(
                                  restaurantId: restaurantId,
                                  villeId: widget.villeData['id'],
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.comment),
                        ),
                        LikeButton(
                          restaurantId: restaurantId,
                          villeId: widget.villeData['id'],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Detail Page for a Specific Restaurant
class RestaurantDetailPage extends StatelessWidget {
  final String villeId;
  final String restaurantId;

  const RestaurantDetailPage({Key? key, required this.villeId, required this.restaurantId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du restaurant'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('ville')
            .doc(villeId)
            .collection('restaurants')
            .doc(restaurantId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des données'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Restaurant non trouvé'));
          }

          var restaurantData = snapshot.data!.data() as Map<String, dynamic>;

          // Retrieve restaurant location from Firestore
          GeoPoint restaurantLocation = restaurantData['localisation'] ?? GeoPoint(0.0, 0.0);

          // Convert GeoPoint to LatLng for flutter_map usage
          LatLng restaurantLatLng = LatLng(restaurantLocation.latitude, restaurantLocation.longitude);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    restaurantData['photo'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    restaurantData['nom'] ?? 'Nom inconnu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    restaurantData['description'] ?? 'Aucune description disponible',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        center: restaurantLatLng,
                        zoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: restaurantLatLng,
                              width: 80.0,
                              height: 80.0,
                              builder: (ctx) => Icon(Icons.location_pin, color: Colors.red, size: 40.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      LikeButton(restaurantId: restaurantId, villeId: villeId),
                      IconButton(
                        icon: Icon(Icons.comment),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentSection(
                                restaurantId: restaurantId,
                                villeId: villeId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  CommentSection(restaurantId: restaurantId, villeId: villeId, isInDetailPage: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



class LikeButton extends StatefulWidget {
  final String restaurantId;
  final String villeId;

  LikeButton({required this.restaurantId, required this.villeId});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  void checkIfLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot likeSnapshot = await FirebaseFirestore.instance
          .collection('ville')
          .doc(widget.villeId)
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('likes')
          .doc(user.uid)
          .get();

      if (likeSnapshot.exists) {
        setState(() {
          isLiked = true;
        });
      }
    }
  }

  void _toggleLike() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference likeRef = FirebaseFirestore.instance
          .collection('ville')
          .doc(widget.villeId)
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('likes')
          .doc(user.uid);

      if (isLiked) {
        await likeRef.delete();
      } else {
        await likeRef.set({
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt),
      onPressed: _toggleLike,
    );
  }
}

class CommentSection extends StatelessWidget {
  final String restaurantId;
  final String villeId;
  final bool isInDetailPage;

  CommentSection({required this.restaurantId, required this.villeId, this.isInDetailPage = false});

  @override
  Widget build(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    void _addComment() async {
      String comment = _commentController.text.trim();
      if (comment.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('ville')
            .doc(villeId)
            .collection('restaurants')
            .doc(restaurantId)
            .collection('comments')
            .add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _commentController.clear();
      }
    }

    Widget commentInputSection() {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Ajouter un commentaire',
                ),
              ),
            ),
            IconButton(
              onPressed: _addComment,
              icon: Icon(Icons.send),
            ),
          ],
        ),
      );
    }

    Widget commentListSection() {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ville')
            .doc(villeId)
            .collection('restaurants')
            .doc(restaurantId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: Text('Aucun commentaire'));
          return ListView(
            shrinkWrap: true,
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['comment']),
                subtitle: Text(doc['userId']),
              );
            }).toList(),
          );
        },
      );
    }

    return isInDetailPage
        ? Column(
            children: [
              commentListSection(),
              commentInputSection(),
            ],
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Commentaires'),
            ),
            body: Column(
              children: [
                Expanded(child: commentListSection()),
                commentInputSection(),
              ],
            ),
          );
  }
}








class LieuxPage extends StatefulWidget {
  final Map<String, dynamic> villeData;

  const LieuxPage({Key? key, required this.villeData}) : super(key: key);

  @override
  _LieuxPageState createState() => _LieuxPageState();
}

class _LieuxPageState extends State<LieuxPage> {
  String? categorieSelectionnee;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.villeData['nom']} - Lieux à visiter'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                categorieSelectionnee = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Plage',
                child: Text('Plage'),
              ),
              PopupMenuItem<String>(
                value: 'Montagnes',
                child: Text('Montagnes'),
              ),
              PopupMenuItem<String>(
                value: 'Marais',
                child: Text('Marais'),
              ),
              PopupMenuItem<String>(
                value: 'Palmiers',
                child: Text('Palmiers'),
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
                .collection('lieux')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur de chargement des données'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Aucun lieu à visiter disponible'));
              }

              // Filtrer les lieux en fonction de la catégorie sélectionnée et de la recherche
              List<DocumentSnapshot> filteredLieux = snapshot.data!.docs
                  .where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return (categorieSelectionnee == null ||
                        data['categorie'] == categorieSelectionnee) &&
                    data['nom'].toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredLieux.isEmpty) {
                return Center(
                    child: Text('Aucun lieu correspondant à cette catégorie'));
              }

              return GridView.builder(
                padding: EdgeInsets.only(top: 80.0), // Espace pour la barre de recherche flottante
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredLieux.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> lieuData =
                      filteredLieux[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LieuDetailsPage(lieuData: lieuData),
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
                                lieuData['photo'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              lieuData['nom'],
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
                  hintText: 'Rechercher un lieu...',
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


class LieuDetailsPage extends StatelessWidget {
  final Map<String, dynamic> lieuData;

  const LieuDetailsPage({Key? key, required this.lieuData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lieuData['nom']),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImagePage(imageUrl: lieuData['photo']),
                    ),
                  );
                },
                child: Hero(
                  tag: 'imageHero',
                  child: Image.network(
                    lieuData['photo'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lieuData['nom'],
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    lieuData['description'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  SizedBox(height: 16),
                  Text(
                    'Galerie de photos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: lieuData['photos'].length,
                    itemBuilder: (BuildContext context, int index) {
                      String photoUrl = lieuData['photos'][index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImagePage(imageUrl: photoUrl),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }
}