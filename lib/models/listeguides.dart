import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Guide extends StatefulWidget {
  const Guide({Key? key}) : super(key: key);

  @override
  State<Guide> createState() => _GuideState();
}

class _GuideState extends State<Guide> {
  String? selectedCity;
  List<String> selectedLanguages = [];
  List<String> cities = [];
  final List<String> languages = ['Arabe', 'Français', 'Anglais', 'Espagnol'];

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('ville').get();
      if (querySnapshot.docs.isEmpty) {
        print('No cities found in Firestore.');
        return;
      }
      setState(() {
        cities = querySnapshot.docs.map((doc) => doc['nom'] as String).toList();
      });
      print('Cities fetched: $cities');
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  void _submitForm() {
    if (selectedCity != null && selectedLanguages.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuideListPage(selectedCity: selectedCity!, selectedLanguages: selectedLanguages),
        ),
      );
    } else {
      print('Sélectionnez une ville et au moins une langue');
    }
  }

  void _viewRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre un guide',style: TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.list, color: Colors.black,),
            onPressed: _viewRequests,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vous voulez prendre un guide dans quelle ville ?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      hint: const Text('Sélectionnez une ville'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vous voulez que le guide parle quelles langues ?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: languages.map((String language) {
                        return CheckboxListTile(
                          title: Text(language),
                          value: selectedLanguages.contains(language),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedLanguages.add(language);
                              } else {
                                selectedLanguages.remove(language);
                              }
                            });
                          },
                          activeColor: const Color.fromRGBO(56, 142, 60, 1),
                          checkColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Soumettre'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Fetch requests from Firestore for the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('demandes')
          .where('user_id', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No requests found in Firestore.');
        return;
      }

      setState(() {
        requests = querySnapshot.docs;
      });
      print('Requests fetched: $requests');
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes demandes',style: TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: requests.isEmpty
          ? Center(child: Text('Aucune demande trouvée.',
            style: TextStyle(
            fontSize: 18, // augmente la taille du texte
            color: Colors.black, // change la couleur du texte en noir
          ),
          ))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];

                // Determine which icon to show based on status
                IconData iconData;
                Color iconColor;

                switch (request['status']) {
                  case 'accepté':
                    iconData = Icons.check_circle;
                    iconColor = Colors.green;
                    break;
                  case 'refusé':
                    iconData = Icons.cancel;
                    iconColor = Colors.red;
                    break;
                  case 'en attente':
                  default:
                    iconData = Icons.hourglass_empty;
                    iconColor = Colors.orange;
                    break;
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      // Navigate to request details page and pass request data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailsPage(request: request),
                        ),
                      );

                      // If status is 'accepté', show a message dialog
                      if (request['status'] == 'accepté') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Message de guide'),
                            content: Text('Je vous contacterai dans les plus brefs délais.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: ListTile(
                      title: Text('Demande vers ${request['guide_nom']}'),
                      subtitle: Text('Guide: ${request['guide_nom']}'),
                      leading: Icon(iconData, color: iconColor),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class RequestDetailsPage extends StatelessWidget {
  final DocumentSnapshot request;

  const RequestDetailsPage({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la demande',style: TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Guide', request['guide_nom']),
                _buildDetailItem('Numéro de guide', request['guide_numero']),
                _buildDetailItem('Statut', request['status']),
                _buildDetailItem('Ville', request['ville']),
                _buildDetailItem('Date de la demande', _formatDate(request['date'])),
                if (request['status'] == 'accepté')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Je vous contacterai dans les plus brefs délais.',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _cancelRequest(context),
                    child: const Text('Annuler demande'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Divider(),
        const SizedBox(height: 10),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  void _cancelRequest(BuildContext context) async {
    try {
      // Supprimer le document de la collection demandes
      await FirebaseFirestore.instance.collection('demandes').doc(request.id).delete();
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Demande annulée avec succès'),
        duration: Duration(seconds: 2),
      ));
      // Naviguer vers une autre page ou afficher une action supplémentaire si nécessaire
      // Navigator.of(context).pop(); // Exemple : retourner à la page précédente
    } catch (e) {
      print('Error cancelling request: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'annulation et suppression de la demande'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}


class GuideListPage extends StatefulWidget {
  final String selectedCity;
  final List<String> selectedLanguages;

  const GuideListPage({
    required this.selectedCity,
    required this.selectedLanguages,
  });

  @override
  State<GuideListPage> createState() => _GuideListPageState();
}

class _GuideListPageState extends State<GuideListPage> {
  List<Map<String, dynamic>> guides = [];

  @override
  void initState() {
    super.initState();
    _fetchGuides();
  }

  Future<void> _fetchGuides() async {
    try {
      print('Fetching guides from Firestore...');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('guides').get();
      if (querySnapshot.docs.isEmpty) {
        print('No guides found in Firestore.');
        return;
      }

      List<Map<String, dynamic>> allGuides = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include the document ID
        return data;
      }).toList();

      print('All guides from Firestore: $allGuides');

      setState(() {
        guides = allGuides.where((guide) {
          List<dynamic> guideCities = guide['ville'] as List<dynamic>;
          List<dynamic> guideLanguages = guide['langue'] as List<dynamic>;

          bool matchesCity = guideCities.contains(widget.selectedCity);
          bool matchesLanguages = widget.selectedLanguages.every((lang) => guideLanguages.contains(lang));

          print('Guide: $guide');
          print('matchesCity: $matchesCity');
          print('matchesLanguages: $matchesLanguages');

          return matchesCity && matchesLanguages;
        }).toList();

        print('Filtered guides: $guides');
      });
    } catch (e) {
      print('Error fetching guides: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des guides',style: TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: guides.isEmpty
            ? Center(child: Text('Aucun guide disponible pour les critères sélectionnés.'))
            : ListView.builder(
                itemCount: guides.length,
                itemBuilder: (context, index) {
                  final guide = guides[index];
                  return GestureDetector(
                    onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuideDetailsPage(
                          guide: guide,
                          selectedCity: widget.selectedCity,
                        ),
                      ),
                    );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(guide['photo']),
                        ),
                        title: Text('${guide['prenom']} ${guide['nom']}'),
                        subtitle: Text('${guide['langue'].join(', ')}'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class GuideDetailsPage extends StatelessWidget {
  final Map<String, dynamic> guide;
  final String selectedCity;
  final TextEditingController phoneController = TextEditingController(); // Controller pour le champ de saisie du numéro

  GuideDetailsPage({Key? key, required this.guide, required this.selectedCity}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${guide['prenom']} ${guide['nom']}'),
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  tag: 'guide_photo_${guide['id']}',
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(guide['photo']),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${guide['prenom']} ${guide['nom']}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Numéro: ${guide['numero']}'),
              Text('Prix: ${guide['prix']} MRU'),
              Text('Langues: ${guide['langue'].join(', ')}'),
              Row(
                children: [
                  Text('Disponible: '),
                  Icon(
                    guide['disponible'] ? Icons.check_circle : Icons.cancel,
                    color: guide['disponible'] ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _sendRequest(context, phoneController.text);
                  },
                  child: const Text('Envoyer une demande'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendRequest(BuildContext context, String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Numéro de téléphone requis'),
              content: Text('Veuillez entrer votre numéro de téléphone avant d\'envoyer la demande.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('User is not authenticated');
        return;
      }

      CollectionReference demandes = FirebaseFirestore.instance.collection('demandes');
        await demandes.add({
        'user_id': user.uid,
        'guide_id': guide['id'],
        'guide_nom': '${guide['prenom']} ${guide['nom']}',
        'guide_numero': guide['numero'],
        'ville': selectedCity, // Ajouter la ville sélectionnée à la demande
        'date': FieldValue.serverTimestamp(),
        'status': 'pending',
        'phone_number': phoneNumber, // Ajouter le numéro de téléphone à la demande
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Demande envoyée'),
            content: Text('Votre demande a été envoyée au guide ${guide['prenom']} ${guide['nom']} avec le numéro $phoneNumber.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error sending request: $e');
    }
  }
}