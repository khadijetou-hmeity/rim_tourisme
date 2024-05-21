import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rim_tourisme/login/login.dart';
import 'VillePage.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 58, 183, 127),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.location_city,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Villes',
                style: TextStyle(
                  color: Colors.black,
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
              leading: Icon(
                Icons.home,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Logements',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Mettez ici le code pour gérer le tap sur Logements
              },
            ),
            ListTile(
              leading: Icon(
                Icons.location_on,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Meilleurs lieux à visiter',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Mettez ici le code pour gérer le tap sur Meilleurs lieux à visiter
              },
            ),
            ListTile(
              leading: Icon(
                Icons.restaurant,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Restaurants',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Mettez ici le code pour gérer le tap sur Restaurants
              },
            ),
            ListTile(
              leading: Icon(
                Icons.business,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Nos services',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Mettez ici le code pour gérer le tap sur Nos services
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(255, 58, 183, 127),
            floating: false,
            pinned: true,
            expandedHeight: 180.0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                'RIMTourisme',
                style: TextStyle(color: Color.fromARGB(186, 0, 0, 0), fontSize: 18),
              ),
              background: Container(
                color: Color.fromARGB(255, 85, 210, 154),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                icon: Icon(Icons.exit_to_app, color: Colors.black),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildCategoryTile('Plage', 'assets/icons/beach-sunny-svgrepo-com.svg'),
                  _buildCategoryTile('Montagne', 'assets/icons/mountain-svgrepo-com.svg'),
                  _buildCategoryTile('Marais', 'assets/icons/wetland-svgrepo-com.svg'),
                  _buildCategoryTile('Palmiers', 'assets/icons/palm-trees-svgrepo-com.svg'),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildPlaceCard('Chinguitti', 'assets/images/chngi6i.jpg'),
                _buildPlaceCard('Port', 'assets/images/gareb.jpg'),
                _buildPlaceCard('Plage', 'assets/images/leb7ar.jpg'),
                _buildPlaceCard('Ayoun', 'assets/images/lekhrive.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String title, String svgAssetPath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
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
          SizedBox(height: 8.0),
          Text(title, style: TextStyle(fontSize: 13.0)),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(String placeName, String imagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
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
                    placeName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.comment),
                      ),
                      IconButton(
                        onPressed: () {
                          // Mettez ici le code pour gérer les favoris
                        },
                        icon: Icon(Icons.favorite_border),
                      ),
                    ],
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

class VilleListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Villes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ville').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune ville trouvée'));
          }

          var villes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: villes.length,
            itemBuilder: (context, index) {
              var ville = villes[index];
              return ListTile(
                title: Text(ville['nom']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VillePage(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
