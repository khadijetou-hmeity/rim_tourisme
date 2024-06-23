import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rim_tourisme/models/favoris.dart';


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
        title: Text('${widget.villeData['nom']} - Lieux à visiter',style: TextStyle(fontSize: 18)),
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
                categorieSelectionnee = value;
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
                child: Text('Lieux Historique'),
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
              List<DocumentSnapshot> filteredLieux =
                  snapshot.data!.docs.where((doc) {
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
                padding: EdgeInsets.only(
                    top: 80.0), // Espace pour la barre de recherche flottante
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
                          builder: (context) => LieuDetailsPage(
                              villeId: widget.villeData['id'],
                              villeNom: widget.villeData['nom'],
                              lieuData: lieuData),
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
                                fontSize: 14.0,
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

class LieuDetailsPage extends StatefulWidget {
  final String villeId;
  final String villeNom;
  final Map<String, dynamic> lieuData;

  const LieuDetailsPage({
    Key? key,
    required this.villeId,
    required this.villeNom,
    required this.lieuData,
  }) : super(key: key);

  @override
  _LieuDetailsPageState createState() => _LieuDetailsPageState();
}

class _LieuDetailsPageState extends State<LieuDetailsPage> {
  late List<String> photos;
  double? _distanceInMeters;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _calculateDistance();
  }

  void _loadPhotos() {
    if (widget.lieuData.containsKey('photos') &&
        widget.lieuData['photos'] != null) {
      photos = List<String>.from(widget.lieuData['photos']);
    } else {
      photos = [];
    }
  }

  Future<void> _calculateDistance() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double distanceInMeters = await Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          widget.lieuData['localisation'].latitude,
          widget.lieuData['localisation'].longitude);

      setState(() {
        _distanceInMeters = distanceInMeters;
      });
    } catch (e) {
      print('Erreur lors du calcul de la distance : $e');
    }
  }

Future<void> _launchMaps() async {
  if (widget.lieuData['localisation'] != null) {
    GeoPoint geoPoint = widget.lieuData['localisation'];
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
    GeoPoint geoPoint = widget.lieuData['localisation'];
    double latitude = geoPoint.latitude;
    double longitude = geoPoint.longitude;
    LatLng location = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.lieuData['nom']} - ${widget.villeNom}',style: TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          FavoriteButton(
            lieuId: widget.lieuData['id'],
            villeId: widget.villeId,
            lieuData: widget.lieuData,
            villeNom: widget.villeNom,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 7 / 5,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImagePage(
                        imageUrl: widget.lieuData['photo']
                        
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'imageHero',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.lieuData['photo'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.lieuData['nom']} - ${widget.villeNom}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.lieuData['description'],
                    style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 33, 31, 31)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: photos.map((photoUrl) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                      FullScreenImagePage(imageUrl: photoUrl),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  width: 150,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carte de localisation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
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
                              child: Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Affichage de la distance à l'utilisateur
                  Text(
                    _distanceInMeters != null
                        ? 'Distance: ${(_distanceInMeters! / 1000).toStringAsFixed(2)} km'
                        : 'Calcul de la distance...',
                    style: TextStyle(fontSize: 16),
                  ),

                  // Bouton pour voir la route sur Google Maps
                  ElevatedButton(
                    onPressed: _launchMaps,
                    child: Text('Voir la route sur Google Maps',style: TextStyle(color: Colors.green),),
                  ),

                  // Autres widgets
                  // ...
                ],
              ),
            ),
          ],
        ),
      ),
  
      bottomNavigationBar: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      LikeButton(
        lieuId: widget.lieuData['id'], 
        villeId: widget.villeId
      ),
      SizedBox(width: 80), // Ajouter un espace entre les boutons
      CommentButton(
        lieuId: widget.lieuData['id'], 
        villeId: widget.villeId
      ),
    ],
  ),
),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

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
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class LikeButton extends StatefulWidget {
  final String lieuId;
  final String villeId;

  LikeButton({required this.lieuId, required this.villeId});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;
  int likeCount = 1;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
    getLikeCount();
  }

  void checkIfLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot likeSnapshot = await FirebaseFirestore.instance
          .collection('ville')
          .doc(widget.villeId)
          .collection('lieux')
          .doc(widget.lieuId)
          .collection('likes')
          .doc(user.uid)
          .get();

      setState(() {
        isLiked = likeSnapshot.exists;
      });
    }
  }

  void getLikeCount() async {
    QuerySnapshot likesSnapshot = await FirebaseFirestore.instance
        .collection('ville')
        .doc(widget.villeId)
        .collection('lieux')
        .doc(widget.lieuId)
        .collection('likes')
        .get();

    setState(() {
      likeCount = likesSnapshot.docs.length;
    });
  }

  void _toggleLike() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference likeRef = FirebaseFirestore.instance
          .collection('ville')
          .doc(widget.villeId)
          .collection('lieux')
          .doc(widget.lieuId)
          .collection('likes')
          .doc(user.uid);

      if (isLiked) {
        await likeRef.delete();
        setState(() {
          likeCount -= 1;
        });
      } else {
        await likeRef.set({
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          likeCount += 1;
        });
      }

      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt),
          iconSize: 35,
          onPressed: _toggleLike,
        ),
        Text('$likeCount'),
      ],
    );
  }
}

class CommentButton extends StatelessWidget {
  final String lieuId;
  final String villeId;

  CommentButton({required this.lieuId, required this.villeId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CommentSection(lieuId: lieuId, villeId: villeId),
          ),
        );
      },
      icon: SvgPicture.asset(
        'assets/icons/comments-lines-svgrepo-com.svg', // Assurez-vous de mettre le chemin correct vers votre fichier SVG
        width: 45, // Ajustez la taille selon vos préférences
        height: 45,
        color: Colors.black,
        // Couleur de l'icône
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  final String lieuId;
  final String villeId;

  CommentSection({required this.lieuId, required this.villeId});

  @override
  Widget build(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    // Ajouter un commentaire avec une horodatage de serveur
    void _addComment() async {
      String comment = _commentController.text.trim();
      if (comment.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Map<String, dynamic> commentData = {
            'userId': user.uid,
            'comment': comment,
            'timestamp': FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('ville')
              .doc(villeId)
              .collection('lieux')
              .doc(lieuId)
              .collection('comments')
              .add(commentData);

          _commentController.clear();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Commentaires'),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('ville')
                  .doc(villeId)
                  .collection('lieux')
                  .doc(lieuId)
                  .collection('comments')
                  .orderBy('timestamp',
                      descending:
                          true) // Pour afficher les commentaires les plus récents en premier
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> commentData =
                          document.data() as Map<String, dynamic>;
                      String comment = commentData['comment'];
                      String userId = commentData[
                          'userId']; // Récupérer l'ID de l'utilisateur

                      // Requête Firestore pour récupérer les informations de l'utilisateur
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Indicateur de chargement pendant la récupération des informations de l'utilisateur
                          }

                          if (userSnapshot.hasError) {
                            return Text(
                                'Erreur de chargement des données de l\'utilisateur');
                          }

                          if (userSnapshot.hasData) {
                            Map<String, dynamic> userData = userSnapshot.data!
                                .data() as Map<String, dynamic>;
                            String userName =
                                '${userData['Prénom']} ${userData['Nom']}'; // Nom complet de l'utilisateur

                            return ListTile(
                              title: Text(comment),
                              subtitle: Text(
                                  userName), // Afficher le nom complet de l'utilisateur en tant que sous-titre du commentaire
                            );
                          }

                          return Text('Utilisateur non trouvé');
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Center(
                    child:
                        CircularProgressIndicator(), // Afficher une indication de chargement pendant le chargement des commentaires
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          ),
        ],
      ),
    );
  }
}



