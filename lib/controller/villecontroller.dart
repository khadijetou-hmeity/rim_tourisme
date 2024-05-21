import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rim_tourisme/models/restaut.dart';


Future<Map<String, dynamic>> getCityData(String cityId) async {
  DocumentSnapshot citySnapshot = await FirebaseFirestore.instance.collection('ville').doc(cityId).get();

  List<Restaurant> restaurants = [];
  List<Hotel> hotels = [];

  QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
      .collection('ville')
      .doc(cityId)
      .collection('restaurants')
      .get();

  restaurants = restaurantSnapshot.docs.map((doc) => Restaurant.fromDocument(doc)).toList();

  QuerySnapshot hotelSnapshot = await FirebaseFirestore.instance
      .collection('ville')
      .doc(cityId)
      .collection('hotels')
      .get();

  hotels = hotelSnapshot.docs.map((doc) => Hotel.fromDocument(doc)).toList();

  return {
    'city': citySnapshot.data()!,
    'restaurants': restaurants,
    'hotels': hotels,
  };
}
