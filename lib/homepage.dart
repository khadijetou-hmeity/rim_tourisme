import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rim_tourisme/login/login.dart';
import 'package:rim_tourisme/models/ListeRestaurants.dart';
import 'package:rim_tourisme/models/favoris.dart';
import 'package:rim_tourisme/models/lieux.dart';
import 'package:rim_tourisme/models/listeguides.dart';
import 'package:rim_tourisme/models/listelogment.dart';
import 'package:rim_tourisme/models/meilleursLieux.dart';
import 'VillePage.dart';

class SimpleProject extends StatelessWidget {
  const SimpleProject({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(56, 142, 60, 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/logoRimTourisme2.jpg',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 30.0),
                ],
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/city-svgrepo-com (1).svg',
                width: 30,
                height: 30,
                color: Colors.black,
              ),
              title: Text(
                'Villes',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VillePage()),
                );
              },
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/hotel-building-svgrepo-com.svg',
                width: 30,
                height: 30,
              ),
              title: Text(
                'Meilleurs Hotels',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogementT()),
                );
              },
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/place-ui-pin-svgrepo-com.svg',
                width: 30,
                height: 30,
              ),
              title: Text(
                'Meilleurs Lieux',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Meilleurs()),
                );
              },
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/restaurant-svgrepo-com (2).svg',
                width: 30,
                height: 30,
              ),
              title: Text(
                'Meilleurs Restaurants',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RestaurantListe()),
                );
              },
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/service-svgrepo-com.svg',
                width: 30,
                height: 30,
              ),
              title: Text(
                'Prendre un guide',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Guide()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.black,),
              title: Text(
                'Déconnexion',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
              expandedHeight: 200.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'RIM Tourisme           ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(56, 142, 60, 1),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(60),
                    ),
                  ),
                ),
              ),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(60),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoritesPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    }
                  },
                  icon: Icon(Icons.favorite, color: Color.fromARGB(255, 108, 1, 1)),
                ),
              ],
              titleSpacing: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '   Choisissez votre centre d\'intérêt des lieux !',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: 8.0),
                          _buildCategoryTile(context, 'Plage', 'assets/icons/beach-sunny-svgrepo-com.svg'),
                          SizedBox(width: 8.0),
                          _buildCategoryTile(context, 'Montagnes', 'assets/icons/mountain-svgrepo-com.svg'),
                          SizedBox(width: 8.0),
                          _buildCategoryTile(context, 'Lacs', 'assets/icons/wetland-svgrepo-com.svg'),
                          SizedBox(width: 8.0),
                          _buildCategoryTile(context, 'Oasis', 'assets/icons/palm-trees-svgrepo-com.svg'),
                          SizedBox(width: 8.0),
                          _buildCategoryTile(context, 'Historique', 'assets/icons/ruins-svgrepo-com.svg'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => VillePage()),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                'assets/images/culture6.jpeg', // Replace with your image asset path
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Explorez la richesse de nos cultures à travers une variété de traditions, événements et plus encore.',
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                            
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Meilleurs()),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                'assets/images/Ou-allez.jpeg', // Replace with your image asset path
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Partez à la découverte des trésors cachés de la Mauritanie pour des moments mémorables.',
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                            
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Guide()),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                'assets/images/guide.jpeg', // Replace with your image asset path
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Prenez un guide touristique pour découvrir les trésors cachés de la Mauritanie.',
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                            
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCategoryTile(BuildContext context, String title, String svgAssetPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LieuxCategoriePage(categorie: title),
          ),
        );
      },
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(56, 142, 60, 0.718),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAssetPath,
              width: 40,
              height: 40,
            ),
            SizedBox(height: 4.0),
            Text(title, style: TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}


class LieuxCategoriePage extends StatefulWidget {
  final String categorie;

  LieuxCategoriePage({required this.categorie});

  @override
  _LieuxCategoriePageState createState() => _LieuxCategoriePageState();
}

class _LieuxCategoriePageState extends State<LieuxCategoriePage> {
  late Future<List<Map<String, dynamic>>> _futureLieux;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _futureLieux = _fetchLieuxParCategorie(widget.categorie);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchLieuxParCategorie(String categorie) async {
    List<Map<String, dynamic>> lieux = [];
    QuerySnapshot villesSnapshot = await FirebaseFirestore.instance.collection('ville').get();
    for (var ville in villesSnapshot.docs) {
      QuerySnapshot lieuxSnapshot = await ville.reference.collection('lieux').where('categorie', isEqualTo: categorie).get();
      for (var lieu in lieuxSnapshot.docs) {
        lieux.add({
          'villeId': ville.id,
          'villeNom': ville['nom'],
          'lieuData': lieu.data() as Map<String, dynamic>,
        });
      }
    }
    return lieux;
  }

  List<Map<String, dynamic>> _filterLieux(List<Map<String, dynamic>> lieux, String query) {
    if (query.isEmpty) {
      return lieux;
    }

    return lieux.where((lieu) {
      final String lieuNom = lieu['lieuData']['nom'].toString().toLowerCase();
      return lieuNom.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categorie}',style: TextStyle(fontSize: 18),),
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
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureLieux,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                var lieux = snapshot.data ?? [];
                var filteredLieux = _filterLieux(lieux, _searchController.text);

                if (filteredLieux.isEmpty) {
                  return Center(child: Text('Aucun lieu trouvé pour cette catégorie.'));
                }

                return ListView.builder(
                  itemCount: filteredLieux.length,
                  itemBuilder: (context, index) {
                    var lieu = filteredLieux[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      child: ListTile(
                        leading: Image.network(
                          lieu['lieuData']['photo'] ?? 'https://via.placeholder.com/150',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          lieu['lieuData']['nom'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(lieu['villeNom']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LieuDetailsPage(
                                villeId: lieu['villeId'],
                                villeNom: lieu['villeNom'],
                                lieuData: lieu['lieuData'],
                              ),
                            ),
                          );
                        },
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