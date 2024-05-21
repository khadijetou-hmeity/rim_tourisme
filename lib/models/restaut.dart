import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HotelPage extends StatelessWidget {
  final Map<String, dynamic> villeData;

  const HotelPage({Key? key, required this.villeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${villeData['nom']} - Hotels'),
      ),
      body: Center(
        child: Text('List of hotels in ${villeData['nom']}'),
      ),
    );
  }
}

class RestaurantPage extends StatelessWidget {
  final Map<String, dynamic> villeData;

  const RestaurantPage({Key? key, required this.villeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${villeData['nom']} - Restaurants'),
      ),
      body: Center(
        child: Text('List of restaurants in ${villeData['nom']}'),
      ),
    );
  }
}
class LieuxPage extends StatelessWidget {
  final Map<String, dynamic> villeData;

  const LieuxPage({Key? key, required this.villeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${villeData['nom']} - Lieux à visiter'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ville')
            .doc(villeData['id']) // Suppose que 'id' est le champ d'identifiant de la ville
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
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> lieuData = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    lieuData['photo'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(lieuData['nom']),
                // Ajoutez d'autres détails du lieu ici si nécessaire
              );
            }).toList(),
          );
        },
      ),
    );
  }
}