import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rim_tourisme/homepage.dart'; // Assurez-vous d'importer la page d'accueil
import 'package:country_list_pick/country_list_pick.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late String _selectedCountry = 'Mauritanie'; // Pays sélectionné par défaut
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Méthode pour gérer l'inscription de l'utilisateur
  void _signUp() async {
    // Récupérer les valeurs saisies dans les champs de texte
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String age = _ageController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validation de mot de passe
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Envoi d'un email de vérification
      await credential.user!.sendEmailVerification();

      // Rediriger vers la page d'attente de vérification après l'inscription réussie
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmailVerificationPage()),
      );

      // Enregistrer les données de l'utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'Prénom': firstName,
        'Nom': lastName,
        'Email': email,
        'Âge': int.parse(age),
        'Pays': _selectedCountry,
        'password':password,
        'userId': credential.user!.uid,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le mot de passe est trop faible')),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Un compte existe déjà pour cet email')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
      shape: ContinuousRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(30), // Coin inférieur gauche arrondi
      bottomRight: Radius.circular(30), // Coin inférieur droit arrondi
    ),
  ),  
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Âge',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Votre pays',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: _selectedCountry),
                    decoration: InputDecoration(
                      
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  CountryListPick(
                    theme: CountryTheme(
                      isShowFlag: true,
                      isShowTitle: true,
                      isShowCode: false,
                      isDownIcon: true,
                      showEnglishName: true,
                    ),
                    onChanged: (CountryCode? code) {
                      setState(() {
                        _selectedCountry = code!.name!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 1),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              Center(
  child: SizedBox(
    width: 200, // Définissez la largeur souhaitée ici
    child: TextButton(
      onPressed: _signUp,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(56, 142, 60, 1)),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(15)),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: Text(
        'S\'inscrire',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
}

// Page d'attente de vérification de l'email
class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late User _user;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    _user = FirebaseAuth.instance.currentUser!;
    await _user.reload();
    if (_user.emailVerified) {
      _timer.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SimpleProject()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vérification de l\'email'),
        backgroundColor: Color.fromRGBO(56, 142, 60, 1),
      ),
      body: Center(
        child: Text(
          'Un email de vérification a été envoyé à ${_user.email}. Veuillez vérifier votre email.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}