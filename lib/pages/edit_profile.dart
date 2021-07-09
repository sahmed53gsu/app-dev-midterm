import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/helper/helper_functions.dart';
import 'package:group_chat_app/models/user.dart';
import 'package:group_chat_app/pages/home_page.dart';
import 'package:group_chat_app/pages/profile_page.dart';
import 'package:group_chat_app/services/auth_service.dart';

class EditProfile extends StatefulWidget {

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final AuthService _auth = AuthService();
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  String name1;
  String email1;

  getUid() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var uid = user.uid;
    return uid;
  }

  _changeVals(String fullName, String email, String password) async {
    await _auth.updateLogin(fullName, email, password).then((result) async{
      if (result != null) {
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(fullName);

          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: Color(0xFFb5e1eb),
      appBar: AppBar(
        title: Text('Update Profile'),
        backgroundColor: Color(0xFF2a9d8f),
        elevation: 0.0,
      ),
      
      body: ListView(children: <Widget>[
        Container(
            child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(hintText: "New Name"),
                  ),
                  SizedBox( height: 20,),
                  TextField(
                    controller: _email,
                    decoration: InputDecoration(hintText: "New Email"),
                  ),
                ],
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  setState((){
                    name1 = _name.text;
                    email1 = _email.text;
                  });
                  
                  print(name1);
                  print(email1);
                  _changeVals(name1, email1, "");
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage(lst: [name1, email1])));
                },
                child: Text("Update Profile")),
          ],
        ))
      ]),
    );
  }
}