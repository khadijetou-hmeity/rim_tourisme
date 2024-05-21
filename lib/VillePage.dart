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

  List<Map<String, dynamic>> villes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(255, 58, 183, 127),
            floating: false,
            pinned: true,
            expandedHeight: 10.0, // Adjust the height as needed
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                'Villes Page',
                style: TextStyle(color: Color.fromARGB(186, 0, 0, 0), fontSize: 20),
              ),
              background: Container(
                color: Color.fromARGB(255, 85, 210, 154),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  final snapshot = await FirebaseFirestore.instance.collection('ville').get();
                  villes = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
                  showSearch(
                    context: context,
                    delegate: VilleSearchDelegate(villes),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 20.0, // Space between AppBar and list
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _villePageStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Something went wrong')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index].data()! as Map<String, dynamic>;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          data['photo'],
                          width: 80, // Increase the width for a larger image
                          height: 80, // Increase the height for a larger image
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(data['nom']),
                      subtitle: Text(data['type']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VilleDetailPage(villeData: data),
                          ),
                        );
                      },
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class VilleDetailPage extends StatelessWidget {
  final Map<String, dynamic> villeData;

  const VilleDetailPage({Key? key, required this.villeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(villeData['nom']),
        actions: [
          IconButton(
            icon: Icon(Icons.hotel),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelPage(villeData: villeData),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.restaurant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantPage(villeData: villeData),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.place),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LieuxPage(villeData: villeData),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              villeData['photo'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200.0,
            ),
            SizedBox(height: 16.0),
            Text(
              villeData['nom'],
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              villeData['type'],
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Distance: ${villeData['distance']}',
              style: TextStyle(fontSize: 16.0),
            ),
            // Ajoutez d'autres détails ici selon vos besoins
          ],
        ),
      ),
    );
  }
}
class VilleSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> villes;

  VilleSearchDelegate(this.villes);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Map<String, dynamic>> results = villes
        .where((ville) =>
            ville['nom'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              results[index]['photo'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(results[index]['nom']),
          subtitle: Text(results[index]['type']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VilleDetailPage(villeData: results[index]),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestions = villes
        .where((ville) =>
            ville['nom'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              suggestions[index]['photo'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(suggestions[index]['nom']),
          subtitle: Text(suggestions[index]['type']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VilleDetailPage(villeData: suggestions[index]),
              ),
            );
          },
        );
      },
    );
  }
}
