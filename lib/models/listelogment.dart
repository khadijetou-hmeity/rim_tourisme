import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rim_tourisme/models/logement.dart';


class LogementT extends StatefulWidget {
  @override
  _LogementTState createState() => _LogementTState();
}

class _LogementTState extends State<LogementT> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hôtels Touristique',style: TextStyle(fontSize: 18)),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Stack(
        children: [
          HotelList(searchQuery: searchQuery),
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

class HotelList extends StatefulWidget {
  final String searchQuery;

  HotelList({required this.searchQuery});

  @override
  _HotelListState createState() => _HotelListState();
}

class _HotelListState extends State<HotelList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('ville').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Une erreur est survenue.'));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune ville trouvée.'));
        }
        return ListView(
          padding: EdgeInsets.only(top: 80.0), // Espace pour la barre de recherche flottante
          children: snapshot.data!.docs.map((DocumentSnapshot villeDoc) {
            Map<String, dynamic> villeData = villeDoc.data() as Map<String, dynamic>;
            return FutureBuilder(
              future: villeDoc.reference.collection('hotels').where('touristique', isEqualTo: true).get(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> hotelSnapshot) {
                if (hotelSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (hotelSnapshot.hasError || hotelSnapshot.data == null) {
                  return Center(child: Text('Une erreur est survenue.'));
                }
                if (hotelSnapshot.data!.docs.isEmpty) {
                  return SizedBox();
                }

                List<DocumentSnapshot> filteredHotels = hotelSnapshot.data!.docs.where((DocumentSnapshot hotelDoc) {
                  Map<String, dynamic> data = hotelDoc.data() as Map<String, dynamic>;
                  return data['nom'].toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
                         data['description'].toLowerCase().contains(widget.searchQuery.toLowerCase());
                }).toList();

                if (filteredHotels.isEmpty) {
                  return Center(child: Text('Aucun hôtel trouvé pour la recherche.'));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredHotels.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot hotelDoc = filteredHotels[index];
                        Map<String, dynamic> data = hotelDoc.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HotelDetailPage(
                                  hotelData: data,
                                  villeData: villeData,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      data['photo'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    data['nom'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(villeData['nom'], style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

}
